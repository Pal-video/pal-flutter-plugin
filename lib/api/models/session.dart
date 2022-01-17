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

/// request a new session from pal session using this
class PalSessionRequest {}
