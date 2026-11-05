import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/backend_models.dart';
import '../services/backend_business_service.dart';

class EmbeddedHttpServer {
  static final EmbeddedHttpServer _instance = EmbeddedHttpServer._internal();
  factory EmbeddedHttpServer() => _instance;
  EmbeddedHttpServer._internal();

  final BackendBusinessService _service = BackendBusinessService();
  HttpServer? _server;
  int? _port;

  bool get isRunning => _server != null;
  int? get port => _port;
  String? get baseUrl => _port != null ? 'http://127.0.0.1:$_port' : null;

  Future<void> start() async {
    await _service.ensureInitialized();
    if (_server != null || kIsWeb) return;

    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _port = _server!.port;
      _server!.listen(_handleHttpRequest);
    } catch (_) {
      // Caso o ambiente bloqueie abertura de socket (ex: sandbox de teste), opera via dispatchRequest direto
      _server = null;
      _port = null;
    }
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _port = null;
  }

  Future<void> _handleHttpRequest(HttpRequest request) async {
    final response = request.response;
    response.headers.contentType = ContentType.json;

    try {
      final authHeader = request.headers.value(HttpHeaders.authorizationHeader);
      String? token;
      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        token = authHeader.substring(7).trim();
      }

      Map<String, dynamic>? body;
      if (request.method == 'POST' || request.method == 'PUT') {
        final rawBody = await utf8.decoder.bind(request).join();
        if (rawBody.trim().isNotEmpty) {
          body = Map<String, dynamic>.from(jsonDecode(rawBody) as Map);
        }
      }

      final result = await dispatchRequest(
        request.method,
        request.uri.path,
        token: token,
        body: body,
      );

      response.statusCode = HttpStatus.ok;
      response.write(jsonEncode(result));
    } on BackendException catch (e) {
      response.statusCode = e.statusCode;
      response.write(jsonEncode({'error': e.message, 'statusCode': e.statusCode}));
    } catch (e) {
      response.statusCode = HttpStatus.internalServerError;
      response.write(jsonEncode({
        'error': 'Erro interno no servidor.',
        'statusCode': 500,
      }));
    } finally {
      await response.close();
    }
  }

  Future<Map<String, dynamic>> dispatchRequest(
    String method,
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    await _service.ensureInitialized();
    final payload = body ?? <String, dynamic>{};

    if (method == 'GET' && path == '/api/health') {
      return {'status': 'ok'};
    }

    if (method == 'POST' && path == '/api/auth/register') {
      final res = await _service.register(
        name: payload['name'] as String? ?? '',
        email: payload['email'] as String? ?? '',
        password: payload['password'] as String? ?? '',
      );
      return res.toJson();
    }

    if (method == 'POST' && path == '/api/auth/login') {
      final res = await _service.login(
        email: payload['email'] as String? ?? '',
        password: payload['password'] as String? ?? '',
      );
      return res.toJson();
    }

    if (method == 'POST' && path == '/api/auth/logout') {
      await _service.logout(token);
      return {'success': true};
    }

    if (method == 'GET' && path == '/api/profile') {
      final profile = await _service.getProfile(token);
      return profile.toJson();
    }

    if (method == 'PUT' && path == '/api/profile') {
      final profile = await _service.updateProfile(
        token,
        name: payload['name'] as String?,
        email: payload['email'] as String?,
        notificationsEnabled: payload['notificationsEnabled'] as bool?,
        dailyReminder: payload['dailyReminder'] as bool?,
        darkTheme: payload['darkTheme'] as bool?,
      );
      return profile.toJson();
    }

    if (method == 'GET' && path == '/api/modules') {
      final modules = await _service.getModules(token);
      return {
        'modules': modules.map((m) => m.toJson()).toList(),
      };
    }

    if (method == 'POST' && path == '/api/modules/unlock-video') {
      return await _service.unlockModuleWithVideo(
        token,
        moduleId: payload['moduleId'] as String? ?? '',
      );
    }

    if (method == 'POST' && path == '/api/sessions') {
      return await _service.submitSession(
        token,
        moduleId: payload['moduleId'] as String? ?? 'attention',
        score: (payload['score'] as num?)?.toInt() ?? 0,
        durationSeconds: (payload['durationSeconds'] as num?)?.toInt() ?? 30,
      );
    }

    if (method == 'GET' && path == '/api/dashboard') {
      final dashboard = await _service.getDashboard(token);
      return dashboard.toJson();
    }

    if (method == 'GET' && path == '/api/stats') {
      final stats = await _service.getStats(token);
      return stats.toJson();
    }

    throw BackendException(
      statusCode: 404,
      message: 'Rota não encontrada: $method $path',
    );
  }
}

