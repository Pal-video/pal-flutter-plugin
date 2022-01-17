import 'dart:convert';

class PalSession {
  String id;

  PalSession({
    required this.id,
  });

  PalSession copyWith({
    String? id,
  }) {
    return PalSession(
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
    };
  }

  factory PalSession.fromMap(Map<String, dynamic> map) {
    return PalSession(
      id: map['id'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PalSession.fromJson(String source) =>
      PalSession.fromMap(json.decode(source));

  @override
  String toString() => 'PalSession(id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PalSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

String _kFramework = "FLUTTER";

/// request a new session from pal session using this
class PalSessionRequest {
  final String framework;
  final String platform;

  PalSessionRequest({
    required this.framework,
    required this.platform,
  });

  factory PalSessionRequest.create({
    required String platform,
  }) {
    return PalSessionRequest(
      framework: _kFramework,
      platform: platform,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'framework': framework,
      'platform': platform,
    };
  }

  factory PalSessionRequest.fromMap(Map<String, dynamic> map) {
    return PalSessionRequest(
      framework: map['framework'] ?? '',
      platform: map['platform'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PalSessionRequest.fromJson(String source) =>
      PalSessionRequest.fromMap(json.decode(source));

  @override
  String toString() => 'PalSessionRequest(framework: $framework)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PalSessionRequest && other.framework == framework;
  }

  @override
  int get hashCode => framework.hashCode;
}
