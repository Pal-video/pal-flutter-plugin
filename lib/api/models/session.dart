import 'dart:convert';

class PalSession {
  String uid;

  PalSession({
    required this.uid,
  });

  PalSession copyWith({
    String? id,
  }) {
    return PalSession(
      uid: id ?? uid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
    };
  }

  factory PalSession.fromMap(Map<String, dynamic> map) {
    return PalSession(
      uid: map['uid'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PalSession.fromJson(String source) =>
      PalSession.fromMap(json.decode(source));

  @override
  String toString() => 'PalSession(uid: $uid)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PalSession && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}

String _kFramework = "FLUTTER";

/// request a new session from pal session using this
class PalSessionRequest {
  final String frameworkType;
  final String platform;

  PalSessionRequest({
    required this.frameworkType,
    required this.platform,
  });

  factory PalSessionRequest.create({
    required String platform,
  }) {
    return PalSessionRequest(
      frameworkType: _kFramework,
      platform: platform,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'frameworkType': frameworkType,
      'platform': platform,
    };
  }

  factory PalSessionRequest.fromMap(Map<String, dynamic> map) {
    return PalSessionRequest(
      frameworkType: map['frameworkType'] ?? '',
      platform: map['platform'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PalSessionRequest.fromJson(String source) =>
      PalSessionRequest.fromMap(json.decode(source));

  @override
  String toString() => 'PalSessionRequest(framework: $frameworkType)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PalSessionRequest && other.frameworkType == frameworkType;
  }

  @override
  int get hashCode => frameworkType.hashCode;
}
