import 'dart:convert';

enum VideoTriggerEvents {
  videoSkip,
  minVideoOpen,
  answer,
}

// TODO deviceId, userId, or create a sessionId to sync these ???

/// Those events are sent when the user
/// * see the video
/// * skip the video
/// * answer the video
///
class VideoTriggerEvent {
  VideoTriggerEvents type;
  DateTime time;
  String sessionId;
  Map<String, dynamic>? args;

  VideoTriggerEvent({
    required this.time,
    required this.type,
    required this.sessionId,
    this.args,
  });

  factory VideoTriggerEvent.singleChoice(
    String choiceId,
    String sessionId,
  ) =>
      VideoTriggerEvent(
        time: DateTime.now(),
        type: VideoTriggerEvents.answer,
        sessionId: sessionId,
        args: <String, dynamic>{
          'answer': choiceId,
        },
      );

  // VideoTriggerEvent copyWith({
  //   String? videoId,
  //   DateTime? time,
  //   String? sessionId,
  //   VideoTriggerEvents? type,
  //   Map<String, dynamic>? args,
  // }) {
  //   return VideoTriggerEvent(
  //     time: time ?? this.time,
  //     sessionId: sessionId ?? this.sessionId,
  //     type: type ?? this.type,
  //     args: args ?? this.args,
  //   );
  // }

  Map<String, dynamic> toMap() {
    return {
      'time': time.millisecondsSinceEpoch,
      'type': type.name,
      'args': args,
      'sessionId': sessionId,
    };
  }

  factory VideoTriggerEvent.fromMap(Map<String, dynamic> map) {
    return VideoTriggerEvent(
        time: DateTime.fromMillisecondsSinceEpoch(map['time']),
        args: map['args'],
        sessionId: map['sessionId'],
        type: parseType(map['type']));
  }

  String toJson() => json.encode(toMap());

  factory VideoTriggerEvent.fromJson(String source) =>
      VideoTriggerEvent.fromMap(json.decode(source));

  // @override
  // bool operator ==(Object other) {
  //   if (identical(this, other)) return true;

  //   return other is VideoTriggerEvent && other.time == time;
  // }

  // @override
  // int get hashCode => type.hashCode ^ time.hashCode;

  static VideoTriggerEvents parseType(String data) {
    final search =
        VideoTriggerEvents.values.where((element) => element.name == data);
    if (search.isEmpty) {
      throw 'type not found';
    }
    return search.first;
  }
}
