import 'dart:math';
import '../models/backend_models.dart';
import '../storage/local_database.dart';

class BackendBusinessService {
  static final BackendBusinessService _instance = BackendBusinessService._internal();
  factory BackendBusinessService() => _instance;
  BackendBusinessService._internal();

  final LocalDatabase _db = LocalDatabase();

  static const List<Map<String, String>> _moduleCatalog = [
    {
      'id': 'attention',
      'title': 'Atenção Concentrada',
      'description': 'Treine seu foco ignorando distrações.',
      'route': '/game_attention',
    },
    {
      'id': 'memory',
      'title': 'Memória Operacional',
      'description': 'Aumente sua capacidade de reter informações.',
      'route': '/game_memory',
    },
    {
      'id': 'sequence',
      'title': 'Sequência Lógica',
      'description': 'Melhore seu raciocínio de padrões complexos.',
      'route': '/game_sequence',
    },
    {
      'id': 'word_puzzle',
      'title': 'Cruza-Letras',
      'description': 'Desembaralhe palavras e ative a linguagem mental.',
      'route': '/game_word_puzzle',
    },
    {
      'id': 'stroop',
      'title': 'Conflito de Cores',
      'description': 'Efeito Stroop para treinar a inibição cognitiva.',
      'route': '/game_stroop',
    },
    {
      'id': 'math',
      'title': 'Cálculo Rápido',
      'description': 'Matemática mental sob pressão e raciocínio.',
      'route': '/game_math',
    },
    {
      'id': 'nback',
      'title': 'Memória de Trabalho',
      'description': 'Teste N-Back científico de retenção contínua.',
      'route': '/game_nback',
    },
    {
      'id': 'crossword',
      'title': 'Palavras Cruzadas',
      'description': 'Preencha a grade usando o conhecimento cognitivo.',
      'route': '/game_crossword',
    },
  ];

  static const Map<String, String> _sessionTitles = {
    'attention': 'Atenção Concentrada',
    'memory': 'Memória (Cartões)',
    'sequence': 'Sequência Lógica',
    'word_puzzle': 'Cruza-Letras',
    'stroop': 'Conflito de Cores',
    'math': 'Cálculo Rápido',
    'nback': 'Memória de Trabalho',
    'crossword': 'Palavras Cruzadas',
    'zen_mode': 'Modo Zen (Respiração)',
  };

  Future<void> ensureInitialized() async {
    if (!_db.isInitialized) {
      await _db.init();
    }
  }

  Future<AuthResponseDto> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await ensureInitialized();

    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();

    if (cleanName.length < 2) {
      throw const BackendException(
        statusCode: 400,
        message: 'Informe seu nome completo (mínimo 2 caracteres).',
      );
    }
    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      throw const BackendException(
        statusCode: 400,
        message: 'Informe um endereço de e-mail válido.',
      );
    }
    if (password.length < 6) {
      throw const BackendException(
        statusCode: 400,
        message: 'A senha deve possuir pelo menos 6 caracteres.',
      );
    }

    final existing = _db.getUserByEmail(cleanEmail);
    if (existing != null) {
      throw const BackendException(
        statusCode: 409,
        message: 'Este e-mail já está cadastrado.',
      );
    }

    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final userRecord = _db.createDefaultUserRecord(
      id: userId,
      name: cleanName,
      email: cleanEmail,
      passwordHash: LocalDatabase.hashPassword(password),
      isSeedUser: false,
    );

    await _db.saveUser(userId, userRecord);
    final token = _generateToken(userId);
    await _db.saveToken(token, userId);

    return AuthResponseDto(
      token: token,
      user: UserProfileDto.fromJson(userRecord),
    );
  }

  Future<AuthResponseDto> login({
    required String email,
    required String password,
  }) async {
    await ensureInitialized();

    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || password.isEmpty) {
      throw const BackendException(
        statusCode: 400,
        message: 'Preencha seu e-mail e sua senha.',
      );
    }

    final userRecord = _db.getUserByEmail(cleanEmail);
    final expectedHash = LocalDatabase.hashPassword(password);

    if (userRecord == null || userRecord['passwordHash'] != expectedHash) {
      throw const BackendException(
        statusCode: 401,
        message: 'E-mail ou senha incorretos.',
      );
    }

    final userId = userRecord['id'] as String;
    final token = _generateToken(userId);
    await _db.saveToken(token, userId);

    return AuthResponseDto(
      token: token,
      user: UserProfileDto.fromJson(userRecord),
    );
  }

  Future<void> logout(String? token) async {
    await ensureInitialized();
    final targetToken = token ?? _db.activeToken;
    if (targetToken != null) {
      await _db.removeToken(targetToken);
    }
  }

  Map<String, dynamic> resolveAuthorizedUser(String? token) {
    final effectiveToken = (token != null && token.isNotEmpty) ? token : _db.activeToken;
    String? userId = _db.getUserIdByToken(effectiveToken);
    userId ??= 'user_lucas_01';

    final user = _db.getUserById(userId);
    if (user == null) {
      throw const BackendException(
        statusCode: 401,
        message: 'Sessão expirada ou usuário não encontrado.',
      );
    }
    return user;
  }

  Future<UserProfileDto> getProfile(String? token) async {
    await ensureInitialized();
    final user = resolveAuthorizedUser(token);
    return UserProfileDto.fromJson(user);
  }

  Future<UserProfileDto> updateProfile(
    String? token, {
    String? name,
    String? email,
    bool? notificationsEnabled,
    bool? dailyReminder,
    bool? darkTheme,
  }) async {
    await ensureInitialized();
    final user = resolveAuthorizedUser(token);
    final userId = user['id'] as String;

    if (name != null) {
      final cleanName = name.trim();
      if (cleanName.length < 2) {
        throw const BackendException(
          statusCode: 400,
          message: 'O nome deve ter pelo menos 2 caracteres.',
        );
      }
      user['name'] = cleanName;
    }

    if (email != null) {
      final cleanEmail = email.trim().toLowerCase();
      if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
        throw const BackendException(
          statusCode: 400,
          message: 'Informe um e-mail válido.',
        );
      }
      final existing = _db.getUserByEmail(cleanEmail);
      if (existing != null && existing['id'] != userId) {
        throw const BackendException(
          statusCode: 409,
          message: 'Este e-mail já está em uso por outra conta.',
        );
      }
      user['email'] = cleanEmail;
    }

    if (notificationsEnabled != null) {
      user['notificationsEnabled'] = notificationsEnabled;
    }
    if (dailyReminder != null) {
      user['dailyReminder'] = dailyReminder;
    }
    if (darkTheme != null) {
      user['darkTheme'] = darkTheme;
    }

    await _db.saveUser(userId, user);
    return UserProfileDto.fromJson(user);
  }

  Future<List<ModuleStatusDto>> getModules(String? token) async {
    await ensureInitialized();
    final user = resolveAuthorizedUser(token);
    final userModules = Map<String, dynamic>.from(user['modules'] as Map? ?? {});

    return _moduleCatalog.map((catalogItem) {
      final id = catalogItem['id']!;
      final state = Map<String, dynamic>.from(userModules[id] as Map? ?? {});
      final defaultUnlocked = id == 'attention' || id == 'memory' || id == 'sequence';
      return ModuleStatusDto(
        id: id,
        title: catalogItem['title']!,
        description: catalogItem['description']!,
        route: catalogItem['route']!,
        isLocked: state['isLocked'] as bool? ?? !defaultUnlocked,
        progress: ((state['progress'] as num?)?.toDouble() ?? 0.0).clamp(0.0, 1.0),
      );
    }).toList();
  }

  Future<Map<String, dynamic>> unlockModuleWithVideo(
    String? token, {
    required String moduleId,
  }) async {
    await ensureInitialized();
    final user = resolveAuthorizedUser(token);
    final userId = user['id'] as String;

    final exists = _moduleCatalog.any((m) => m['id'] == moduleId);
    if (!exists) {
      throw const BackendException(
        statusCode: 404,
        message: 'Módulo não encontrado.',
      );
    }

    final userModules = Map<String, dynamic>.from(user['modules'] as Map? ?? {});
    final currentModule = Map<String, dynamic>.from(userModules[moduleId] as Map? ?? {});
    currentModule['isLocked'] = false;
    currentModule['progress'] = (currentModule['progress'] as num?)?.toDouble() ?? 0.0;
    userModules[moduleId] = currentModule;
    user['modules'] = userModules;

    final currentCredits = (user['neuroCredits'] as num?)?.toInt() ?? 450;
    const rewardCredits = 50;
    user['neuroCredits'] = currentCredits + rewardCredits;

    await _db.saveUser(userId, user);

    final modules = await getModules(token);
    final unlockedModule = modules.firstWhere((m) => m.id == moduleId);

    return {
      'module': unlockedModule.toJson(),
      'neuroCredits': user['neuroCredits'],
      'rewardedCredits': rewardCredits,
    };
  }

  Future<Map<String, dynamic>> submitSession(
    String? token, {
    required String moduleId,
    required int score,
    required int durationSeconds,
  }) async {
    await ensureInitialized();
    final user = resolveAuthorizedUser(token);
    final userId = user['id'] as String;

    final cleanDuration = durationSeconds.clamp(5, 7200);
    final int earnedPoints = moduleId == 'zen_mode'
        ? (score > 0 ? score.clamp(10, 500) : 25)
        : (score > 0 ? score.clamp(5, 2000) : 10);

    // 1. Atualiza Neuroly Score e ganho semanal
    final currentScore = (user['neurolyScore'] as num?)?.toInt() ?? 985;
    final currentWeeklyGain = (user['weeklyGain'] as num?)?.toInt() ?? 125;
    user['neurolyScore'] = currentScore + earnedPoints;
    user['weeklyGain'] = currentWeeklyGain + earnedPoints;

    // 2. Atualiza Tempo Focado (Hoje e Total)
    final focusedToday = (user['focusedSecondsToday'] as num?)?.toInt() ?? 13500;
    final totalFocused = (user['totalFocusedSeconds'] as num?)?.toInt() ?? 23040;
    user['focusedSecondsToday'] = focusedToday + cleanDuration;
    user['totalFocusedSeconds'] = totalFocused + cleanDuration;

    // 3. Atualiza domínio do módulo jogado
    final userModules = Map<String, dynamic>.from(user['modules'] as Map? ?? {});
    if (userModules.containsKey(moduleId)) {
      final modState = Map<String, dynamic>.from(userModules[moduleId] as Map? ?? {});
      final oldProgress = (modState['progress'] as num?)?.toDouble() ?? 0.0;
      final progressDelta = (earnedPoints / 500.0).clamp(0.05, 0.25);
      modState['isLocked'] = false;
      modState['progress'] = (oldProgress + progressDelta).clamp(0.0, 1.0);
      userModules[moduleId] = modState;
      user['modules'] = userModules;
    }

    // 4. Atualiza Nível Cognitivo Diário
    final oldCognitive = (user['cognitiveLevel'] as num?)?.toDouble() ?? 0.72;
    final cognitiveDelta = (earnedPoints / 2000.0).clamp(0.01, 0.04);
    final newCognitive = (oldCognitive + cognitiveDelta).clamp(0.0, 1.0);
    user['cognitiveLevel'] = newCognitive;

    // 5. Atualiza Missões Diárias e Bônus de Créditos
    int credits = (user['neuroCredits'] as num?)?.toInt() ?? 450;
    int gamesToday = (user['gamesPlayedToday'] as num?)?.toInt() ?? 0;
    if (moduleId != 'zen_mode') {
      gamesToday += 1;
      user['gamesPlayedToday'] = gamesToday;
    }

    final mission1Rewarded = user['mission1Rewarded'] as bool? ?? false;
    if (gamesToday >= 3 && !mission1Rewarded) {
      credits += 25;
      user['mission1Rewarded'] = true;
    }

    final initialCognitive =
        (user['initialDailyCognitiveLevel'] as num?)?.toDouble() ?? 0.70;
    final evolvedPercent = ((newCognitive - initialCognitive) * 100).round();
    final mission2Rewarded = user['mission2Rewarded'] as bool? ?? false;
    if (evolvedPercent >= 5 && !mission2Rewarded) {
      credits += 25;
      user['mission2Rewarded'] = true;
    }

    // Também concede +10 créditos por partida concluída
    credits += 10;
    user['neuroCredits'] = credits;

    // 6. Atualiza curva do gráfico (6 pontos normalizados onde menor Y = maior altura)
    final rawPoints = (user['chartPoints'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        <double>[0.8, 0.6, 0.7, 0.3, 0.4, 0.1];
    final lastY = rawPoints.isNotEmpty ? rawPoints.last : 0.2;
    final nextY = (lastY - 0.03).clamp(0.05, 0.85);
    final updatedChart = [...rawPoints.skip(1), nextY];
    user['chartPoints'] = updatedChart;

    // 7. Registra no Histórico de Sessões
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final sessionRecord = SessionRecordDto(
      id: 'sess_${now.millisecondsSinceEpoch}',
      moduleId: moduleId,
      title: _sessionTitles[moduleId] ?? 'Treino Cognitivo',
      dateLabel: 'Hoje, $hh:$mm',
      pointsLabel: '+$earnedPoints pts',
      points: earnedPoints,
      durationSeconds: cleanDuration,
      timestampIso: now.toIso8601String(),
    );

    final existingSessions = (user['sessions'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    existingSessions.insert(0, sessionRecord.toJson());
    if (existingSessions.length > 20) {
      existingSessions.removeRange(20, existingSessions.length);
    }
    user['sessions'] = existingSessions;

    await _db.saveUser(userId, user);

    return {
      'session': sessionRecord.toJson(),
      'dashboard': (await getDashboard(token)).toJson(),
      'stats': (await getStats(token)).toJson(),
      'profile': UserProfileDto.fromJson(user).toJson(),
    };
  }

  Future<DashboardDto> getDashboard(String? token) async {
    await ensureInitialized();
    final user = resolveAuthorizedUser(token);

    final cognitiveLevel =
        ((user['cognitiveLevel'] as num?)?.toDouble() ?? 0.72).clamp(0.0, 1.0);
    final initialCognitive =
        (user['initialDailyCognitiveLevel'] as num?)?.toDouble() ?? 0.70;
    final gamesPlayedToday = (user['gamesPlayedToday'] as num?)?.toInt() ?? 0;
    final focusedSecondsToday =
        (user['focusedSecondsToday'] as num?)?.toInt() ?? 13500;

    final clampedGames = gamesPlayedToday.clamp(0, 3);
    final evolvedPercent = max(0, ((cognitiveLevel - initialCognitive) * 100).round());

    final missions = [
      MissionDto(
        id: 'play_3_games',
        title: 'Jogar 3 minigames',
        subtitle: '$clampedGames/3 concluídos',
        isCompleted: gamesPlayedToday >= 3,
      ),
      MissionDto(
        id: 'evolve_5_percent',
        title: 'Evoluir seu cérebro em 5%',
        subtitle: 'Progresso atual: $evolvedPercent%',
        isCompleted: evolvedPercent >= 5,
      ),
    ];

    return DashboardDto(
      cognitiveLevel: cognitiveLevel,
      missions: missions,
      formattedTimeToday: _formatDuration(focusedSecondsToday),
      timeProgressToday: (focusedSecondsToday / 33750.0).clamp(0.05, 1.0),
      focusedSecondsToday: focusedSecondsToday,
    );
  }

  Future<StatsDto> getStats(String? token) async {
    await ensureInitialized();
    final user = resolveAuthorizedUser(token);

    final neurolyScore = (user['neurolyScore'] as num?)?.toInt() ?? 985;
    final weeklyGain = (user['weeklyGain'] as num?)?.toInt() ?? 125;
    final totalFocusedSeconds =
        (user['totalFocusedSeconds'] as num?)?.toInt() ?? 23040;
    final chartPoints = (user['chartPoints'] as List<dynamic>? ??
            [0.8, 0.6, 0.7, 0.3, 0.4, 0.1])
        .map((e) => (e as num).toDouble())
        .toList();
    final sessions = (user['sessions'] as List<dynamic>? ?? [])
        .map((e) => SessionRecordDto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return StatsDto(
      neurolyScore: neurolyScore,
      weeklyGain: weeklyGain,
      chartPoints: chartPoints,
      formattedFocusedTime: _formatDuration(totalFocusedSeconds),
      focusedTimeProgress: (totalFocusedSeconds / 35446.0).clamp(0.05, 1.0),
      recentSessions: sessions,
    );
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${max(1, minutes)}m';
  }

  String _generateToken(String userId) {
    final rand = Random().nextInt(999999).toString().padLeft(6, '0');
    return 'tk_${userId}_${DateTime.now().millisecondsSinceEpoch}_$rand';
  }
}

