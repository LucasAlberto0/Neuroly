import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  static const String _dbFileName = 'neuroly_backend_db_v1.json';
  static const String _passwordSalt = 'neuroly_cognitive_salt_v1';

  Map<String, dynamic> _data = {};
  bool _initialized = false;
  File? _dbFile;

  bool get isInitialized => _initialized;

  static String hashPassword(String rawPassword) {
    final bytes = utf8.encode('$_passwordSalt:$rawPassword');
    return sha256.convert(bytes).toString();
  }

  Future<void> init({bool forceInMemory = false}) async {
    if (_initialized && !forceInMemory) return;

    if (!forceInMemory && !kIsWeb) {
      try {
        final dir = await getApplicationSupportDirectory();
        _dbFile = File('${dir.path}/$_dbFileName');
        if (await _dbFile!.exists()) {
          final content = await _dbFile!.readAsString();
          if (content.trim().isNotEmpty) {
            _data = Map<String, dynamic>.from(jsonDecode(content) as Map);
          }
        }
      } catch (_) {
        // Fallback em memória caso path_provider não esteja disponível (ex: ambiente de teste)
        _dbFile = null;
      }
    } else {
      _dbFile = null;
    }

    if (_data.isEmpty || !_data.containsKey('users')) {
      _seedDatabase();
      await save();
    }

    _initialized = true;
  }

  Future<void> resetForTesting() async {
    _data = {};
    _dbFile = null;
    _seedDatabase();
    _initialized = true;
  }

  void _seedDatabase() {
    const defaultUserId = 'user_lucas_01';
    const defaultToken = 'token_seed_lucas_01';

    _data = {
      'users': {
        defaultUserId: createDefaultUserRecord(
          id: defaultUserId,
          name: 'Lucas Alberto',
          email: 'lucas@neuroly.com',
          passwordHash: hashPassword('123456'),
          isSeedUser: true,
        ),
      },
      'tokens': {
        defaultToken: defaultUserId,
      },
      'activeToken': defaultToken,
    };
  }

  Map<String, dynamic> createDefaultUserRecord({
    required String id,
    required String name,
    required String email,
    required String passwordHash,
    bool isSeedUser = false,
  }) {
    return {
      'id': id,
      'name': name,
      'email': email.toLowerCase().trim(),
      'passwordHash': passwordHash,
      'plan': 'Neuroly Pro',
      'neuroCredits': isSeedUser ? 450 : 100,
      'notificationsEnabled': true,
      'dailyReminder': true,
      'darkTheme': true,
      'cognitiveLevel': isSeedUser ? 0.72 : 0.50,
      'initialDailyCognitiveLevel': isSeedUser ? 0.70 : 0.50,
      'gamesPlayedToday': 0,
      'mission1Rewarded': false,
      'mission2Rewarded': false,
      'focusedSecondsToday': isSeedUser ? 13500 : 0, // 3h 45m = 13500s
      'totalFocusedSeconds': isSeedUser ? 23040 : 0, // 6h 24m = 23040s
      'neurolyScore': isSeedUser ? 985 : 500,
      'weeklyGain': isSeedUser ? 125 : 0,
      'chartPoints': isSeedUser
          ? <double>[0.8, 0.6, 0.7, 0.3, 0.4, 0.1]
          : <double>[0.85, 0.80, 0.75, 0.70, 0.65, 0.60],
      'modules': {
        'attention': {'isLocked': false, 'progress': isSeedUser ? 0.45 : 0.0},
        'memory': {'isLocked': false, 'progress': isSeedUser ? 0.80 : 0.0},
        'sequence': {'isLocked': false, 'progress': isSeedUser ? 0.20 : 0.0},
        'word_puzzle': {'isLocked': true, 'progress': 0.0},
        'stroop': {'isLocked': true, 'progress': 0.0},
        'math': {'isLocked': true, 'progress': 0.0},
        'nback': {'isLocked': true, 'progress': 0.0},
        'crossword': {'isLocked': true, 'progress': 0.0},
      },
      'sessions': isSeedUser
          ? [
              {
                'id': 'sess_seed_1',
                'moduleId': 'memory',
                'title': 'Memória (Cartões)',
                'dateLabel': 'Hoje, 14:30',
                'pointsLabel': '+45 pts',
                'points': 45,
                'durationSeconds': 120,
                'timestampIso': DateTime.now()
                    .subtract(const Duration(hours: 2))
                    .toIso8601String(),
              },
              {
                'id': 'sess_seed_2',
                'moduleId': 'attention',
                'title': 'Atenção Concentrada',
                'dateLabel': 'Ontem, 09:15',
                'pointsLabel': '+30 pts',
                'points': 30,
                'durationSeconds': 90,
                'timestampIso': DateTime.now()
                    .subtract(const Duration(days: 1, hours: 3))
                    .toIso8601String(),
              },
              {
                'id': 'sess_seed_3',
                'moduleId': 'sequence',
                'title': 'Sequência Lógica',
                'dateLabel': 'Ontem, 08:45',
                'pointsLabel': '+15 pts',
                'points': 15,
                'durationSeconds': 60,
                'timestampIso': DateTime.now()
                    .subtract(const Duration(days: 1, hours: 4))
                    .toIso8601String(),
              },
            ]
          : <Map<String, dynamic>>[],
    };
  }

  Map<String, dynamic> get usersMap {
    final raw = _data['users'] as Map? ?? {};
    return Map<String, dynamic>.from(raw);
  }

  Map<String, dynamic>? getUserById(String userId) {
    final users = usersMap;
    final user = users[userId];
    if (user == null) return null;
    return Map<String, dynamic>.from(user as Map);
  }

  Map<String, dynamic>? getUserByEmail(String email) {
    final normalized = email.toLowerCase().trim();
    for (final entry in usersMap.entries) {
      final userMap = Map<String, dynamic>.from(entry.value as Map);
      if ((userMap['email'] as String?)?.toLowerCase().trim() == normalized) {
        return userMap;
      }
    }
    return null;
  }

  Future<void> saveUser(String userId, Map<String, dynamic> userRecord) async {
    final users = usersMap;
    users[userId] = userRecord;
    _data['users'] = users;
    await save();
  }

  String? getUserIdByToken(String? token) {
    if (token == null || token.isEmpty) return null;
    final tokens = Map<String, dynamic>.from(_data['tokens'] as Map? ?? {});
    return tokens[token] as String?;
  }

  String? get activeToken => _data['activeToken'] as String?;

  Future<void> saveToken(String token, String userId) async {
    final tokens = Map<String, dynamic>.from(_data['tokens'] as Map? ?? {});
    tokens[token] = userId;
    _data['tokens'] = tokens;
    _data['activeToken'] = token;
    await save();
  }

  Future<void> removeToken(String token) async {
    final tokens = Map<String, dynamic>.from(_data['tokens'] as Map? ?? {});
    tokens.remove(token);
    _data['tokens'] = tokens;
    if (_data['activeToken'] == token) {
      _data['activeToken'] = null;
    }
    await save();
  }

  Future<void> save() async {
    if (_dbFile != null) {
      try {
        await _dbFile!.writeAsString(jsonEncode(_data), flush: true);
      } catch (_) {
        // Ignora falha de IO em ambientes restritos mantendo estado em memória
      }
    }
  }
}

