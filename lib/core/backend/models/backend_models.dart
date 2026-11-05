class BackendException implements Exception {
  final int statusCode;
  final String message;

  const BackendException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => message;
}

class UserProfileDto {
  final String id;
  final String name;
  final String email;
  final String plan;
  final int neuroCredits;
  final bool notificationsEnabled;
  final bool dailyReminder;
  final bool darkTheme;

  const UserProfileDto({
    required this.id,
    required this.name,
    required this.email,
    required this.plan,
    required this.neuroCredits,
    required this.notificationsEnabled,
    required this.dailyReminder,
    required this.darkTheme,
  });

  UserProfileDto copyWith({
    String? name,
    String? email,
    String? plan,
    int? neuroCredits,
    bool? notificationsEnabled,
    bool? dailyReminder,
    bool? darkTheme,
  }) {
    return UserProfileDto(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      plan: plan ?? this.plan,
      neuroCredits: neuroCredits ?? this.neuroCredits,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      darkTheme: darkTheme ?? this.darkTheme,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'plan': plan,
        'neuroCredits': neuroCredits,
        'notificationsEnabled': notificationsEnabled,
        'dailyReminder': dailyReminder,
        'darkTheme': darkTheme,
      };

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      id: json['id'] as String? ?? 'user_default',
      name: json['name'] as String? ?? 'Lucas Alberto',
      email: json['email'] as String? ?? 'lucas@neuroly.com',
      plan: json['plan'] as String? ?? 'Neuroly Pro',
      neuroCredits: (json['neuroCredits'] as num?)?.toInt() ?? 450,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      dailyReminder: json['dailyReminder'] as bool? ?? true,
      darkTheme: json['darkTheme'] as bool? ?? true,
    );
  }
}

class MissionDto {
  final String id;
  final String title;
  final String subtitle;
  final bool isCompleted;

  const MissionDto({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'isCompleted': isCompleted,
      };

  factory MissionDto.fromJson(Map<String, dynamic> json) {
    return MissionDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class DashboardDto {
  final double cognitiveLevel;
  final List<MissionDto> missions;
  final String formattedTimeToday;
  final double timeProgressToday;
  final int focusedSecondsToday;

  const DashboardDto({
    required this.cognitiveLevel,
    required this.missions,
    required this.formattedTimeToday,
    required this.timeProgressToday,
    required this.focusedSecondsToday,
  });

  Map<String, dynamic> toJson() => {
        'cognitiveLevel': cognitiveLevel,
        'missions': missions.map((m) => m.toJson()).toList(),
        'formattedTimeToday': formattedTimeToday,
        'timeProgressToday': timeProgressToday,
        'focusedSecondsToday': focusedSecondsToday,
      };

  factory DashboardDto.fromJson(Map<String, dynamic> json) {
    final rawMissions = json['missions'] as List<dynamic>? ?? [];
    return DashboardDto(
      cognitiveLevel: (json['cognitiveLevel'] as num?)?.toDouble() ?? 0.72,
      missions: rawMissions
          .map((e) => MissionDto.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      formattedTimeToday: json['formattedTimeToday'] as String? ?? '3h 45m',
      timeProgressToday: (json['timeProgressToday'] as num?)?.toDouble() ?? 0.4,
      focusedSecondsToday: (json['focusedSecondsToday'] as num?)?.toInt() ?? 13500,
    );
  }
}

class SessionRecordDto {
  final String id;
  final String moduleId;
  final String title;
  final String dateLabel;
  final String pointsLabel;
  final int points;
  final int durationSeconds;
  final String timestampIso;

  const SessionRecordDto({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.dateLabel,
    required this.pointsLabel,
    required this.points,
    required this.durationSeconds,
    required this.timestampIso,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'moduleId': moduleId,
        'title': title,
        'dateLabel': dateLabel,
        'pointsLabel': pointsLabel,
        'points': points,
        'durationSeconds': durationSeconds,
        'timestampIso': timestampIso,
      };

  factory SessionRecordDto.fromJson(Map<String, dynamic> json) {
    return SessionRecordDto(
      id: json['id'] as String? ?? '',
      moduleId: json['moduleId'] as String? ?? 'memory',
      title: json['title'] as String? ?? '',
      dateLabel: json['dateLabel'] as String? ?? '',
      pointsLabel: json['pointsLabel'] as String? ?? '+0 pts',
      points: (json['points'] as num?)?.toInt() ?? 0,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 30,
      timestampIso: json['timestampIso'] as String? ?? '',
    );
  }
}

class StatsDto {
  final int neurolyScore;
  final int weeklyGain;
  final List<double> chartPoints;
  final String formattedFocusedTime;
  final double focusedTimeProgress;
  final List<SessionRecordDto> recentSessions;

  const StatsDto({
    required this.neurolyScore,
    required this.weeklyGain,
    required this.chartPoints,
    required this.formattedFocusedTime,
    required this.focusedTimeProgress,
    required this.recentSessions,
  });

  Map<String, dynamic> toJson() => {
        'neurolyScore': neurolyScore,
        'weeklyGain': weeklyGain,
        'chartPoints': chartPoints,
        'formattedFocusedTime': formattedFocusedTime,
        'focusedTimeProgress': focusedTimeProgress,
        'recentSessions': recentSessions.map((s) => s.toJson()).toList(),
      };

  factory StatsDto.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['chartPoints'] as List<dynamic>? ?? [0.8, 0.6, 0.7, 0.3, 0.4, 0.1];
    final rawSessions = json['recentSessions'] as List<dynamic>? ?? [];
    return StatsDto(
      neurolyScore: (json['neurolyScore'] as num?)?.toInt() ?? 985,
      weeklyGain: (json['weeklyGain'] as num?)?.toInt() ?? 125,
      chartPoints: rawPoints.map((e) => (e as num).toDouble()).toList(),
      formattedFocusedTime: json['formattedFocusedTime'] as String? ?? '6h 24m',
      focusedTimeProgress: (json['focusedTimeProgress'] as num?)?.toDouble() ?? 0.65,
      recentSessions: rawSessions
          .map((e) => SessionRecordDto.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class ModuleStatusDto {
  final String id;
  final String title;
  final String description;
  final String route;
  final bool isLocked;
  final double progress;

  const ModuleStatusDto({
    required this.id,
    required this.title,
    required this.description,
    required this.route,
    required this.isLocked,
    required this.progress,
  });

  ModuleStatusDto copyWith({
    bool? isLocked,
    double? progress,
  }) {
    return ModuleStatusDto(
      id: id,
      title: title,
      description: description,
      route: route,
      isLocked: isLocked ?? this.isLocked,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'route': route,
        'isLocked': isLocked,
        'progress': progress,
      };

  factory ModuleStatusDto.fromJson(Map<String, dynamic> json) {
    return ModuleStatusDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      route: json['route'] as String? ?? '',
      isLocked: json['isLocked'] as bool? ?? true,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AuthResponseDto {
  final String token;
  final UserProfileDto user;

  const AuthResponseDto({
    required this.token,
    required this.user,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'user': user.toJson(),
      };

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      token: json['token'] as String? ?? '',
      user: UserProfileDto.fromJson(
        Map<String, dynamic>.from(json['user'] as Map? ?? {}),
      ),
    );
  }
}

