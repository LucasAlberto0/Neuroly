import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../backend/models/backend_models.dart';
import '../backend/server/embedded_http_server.dart';
import '../backend/storage/local_database.dart';

class NeurolyApiClient extends ChangeNotifier {
  static final NeurolyApiClient _instance = NeurolyApiClient._internal();
  factory NeurolyApiClient() => _instance;
  NeurolyApiClient._internal();

  final EmbeddedHttpServer _server = EmbeddedHttpServer();
  String? _authToken;
  bool _initialized = false;

  UserProfileDto? _currentUser;
  DashboardDto? _cachedDashboard;
  StatsDto? _cachedStats;
  List<ModuleStatusDto>? _cachedModules;

  UserProfileDto? get currentUser => _currentUser;
  DashboardDto? get cachedDashboard => _cachedDashboard;
  StatsDto? get cachedStats => _cachedStats;
  List<ModuleStatusDto>? get cachedModules => _cachedModules;
  String? get authToken => _authToken;

  Future<void> init() async {
    if (_initialized) return;
    await _server.start();
    _authToken = LocalDatabase().activeToken;
    _initialized = true;
    await refreshAll();
  }

  Future<void> refreshAll() async {
    try {
      await Future.wait([
        fetchProfile(),
        fetchDashboard(),
        fetchStats(),
        fetchModules(),
      ]);
    } catch (_) {
      // Mantém caches existentes caso ocorra falha transitória
    }
  }

  Future<AuthResponseDto> login({
    required String email,
    required String password,
  }) async {
    final json = await _request(
      'POST',
      '/api/auth/login',
      body: {'email': email, 'password': password},
    );
    final res = AuthResponseDto.fromJson(json);
    _authToken = res.token;
    _currentUser = res.user;
    await refreshAll();
    notifyListeners();
    return res;
  }

  Future<AuthResponseDto> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final json = await _request(
      'POST',
      '/api/auth/register',
      body: {'name': name, 'email': email, 'password': password},
    );
    final res = AuthResponseDto.fromJson(json);
    _authToken = res.token;
    _currentUser = res.user;
    await refreshAll();
    notifyListeners();
    return res;
  }

  Future<void> logout() async {
    await _request('POST', '/api/auth/logout');
    _authToken = null;
    notifyListeners();
  }

  Future<UserProfileDto> fetchProfile() async {
    final json = await _request('GET', '/api/profile');
    _currentUser = UserProfileDto.fromJson(json);
    notifyListeners();
    return _currentUser!;
  }

  Future<UserProfileDto> updateProfile({
    String? name,
    String? email,
    bool? notificationsEnabled,
    bool? dailyReminder,
    bool? darkTheme,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (notificationsEnabled != null) body['notificationsEnabled'] = notificationsEnabled;
    if (dailyReminder != null) body['dailyReminder'] = dailyReminder;
    if (darkTheme != null) body['darkTheme'] = darkTheme;

    final json = await _request('PUT', '/api/profile', body: body);
    _currentUser = UserProfileDto.fromJson(json);
    notifyListeners();
    return _currentUser!;
  }

  Future<DashboardDto> fetchDashboard() async {
    final json = await _request('GET', '/api/dashboard');
    _cachedDashboard = DashboardDto.fromJson(json);
    notifyListeners();
    return _cachedDashboard!;
  }

  Future<StatsDto> fetchStats() async {
    final json = await _request('GET', '/api/stats');
    _cachedStats = StatsDto.fromJson(json);
    notifyListeners();
    return _cachedStats!;
  }

  Future<List<ModuleStatusDto>> fetchModules() async {
    final json = await _request('GET', '/api/modules');
    final rawList = json['modules'] as List<dynamic>? ?? [];
    _cachedModules = rawList
        .map((e) => ModuleStatusDto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    notifyListeners();
    return _cachedModules!;
  }

  Future<ModuleStatusDto> unlockModuleWithVideo(String moduleId) async {
    final json = await _request(
      'POST',
      '/api/modules/unlock-video',
      body: {'moduleId': moduleId},
    );
    final unlocked = ModuleStatusDto.fromJson(
      Map<String, dynamic>.from(json['module'] as Map),
    );
    await fetchModules();
    await fetchProfile();
    notifyListeners();
    return unlocked;
  }

  Future<void> submitGameSession({
    required String moduleId,
    required int score,
    required int durationSeconds,
  }) async {
    final json = await _request(
      'POST',
      '/api/sessions',
      body: {
        'moduleId': moduleId,
        'score': score,
        'durationSeconds': durationSeconds,
      },
    );

    if (json['dashboard'] != null) {
      _cachedDashboard = DashboardDto.fromJson(
        Map<String, dynamic>.from(json['dashboard'] as Map),
      );
    }
    if (json['stats'] != null) {
      _cachedStats = StatsDto.fromJson(
        Map<String, dynamic>.from(json['stats'] as Map),
      );
    }
    if (json['profile'] != null) {
      _currentUser = UserProfileDto.fromJson(
        Map<String, dynamic>.from(json['profile'] as Map),
      );
    }
    await fetchModules();
    notifyListeners();
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    if (!_initialized) {
      await _server.start();
      _authToken ??= LocalDatabase().activeToken;
      _initialized = true;
    }

    final baseUrl = _server.baseUrl;
    if (baseUrl != null && !kIsWeb) {
      try {
        final uri = Uri.parse('$baseUrl$path');
        final headers = <String, String>{
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        };

        late http.Response response;
        if (method == 'GET') {
          response = await http.get(uri, headers: headers);
        } else if (method == 'POST') {
          response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
        } else if (method == 'PUT') {
          response = await http.put(
            uri,
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
        } else {
          throw BackendException(statusCode: 405, message: 'Método $method não suportado');
        }

        // Quando TestWidgetsFlutterBinding intercepta HttpClient, retorna 400 com corpo vazio
        if (response.statusCode == 400 && response.body.isEmpty) {
          return await _server.dispatchRequest(
            method,
            path,
            token: _authToken,
            body: body,
          );
        }

        final decoded = response.body.isNotEmpty
            ? Map<String, dynamic>.from(jsonDecode(response.body) as Map)
            : <String, dynamic>{};

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return decoded;
        }

        throw BackendException(
          statusCode: response.statusCode,
          message: decoded['error'] as String? ?? 'Erro na requisição.',
        );
      } on BackendException {
        rethrow;
      } catch (_) {
        // Fallback para dispatch em processo caso o socket local seja interceptado
      }
    }

    return await _server.dispatchRequest(
      method,
      path,
      token: _authToken,
      body: body,
    );
  }
}

