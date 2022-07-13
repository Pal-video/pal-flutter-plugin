import 'dart:convert';

import 'dates.dart';

enum VideoTriggerEvents {
  videoSkip,
  minVideoOpen,
  videoViewed,
  answer,
}

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

  factory VideoTriggerEvent.videoViewed(String sessionId) => VideoTriggerEvent(
        time: DateTime.now(),
        sessionId: sessionId,
        type: VideoTriggerEvents.videoViewed,
      );

  factory VideoTriggerEvent.videoSkipped(String sessionId) => VideoTriggerEvent(
        time: DateTime.now(),
        sessionId: sessionId,
        type: VideoTriggerEvents.videoSkip,
      );

  factory VideoTriggerEvent.videoOpen(String sessionId) => VideoTriggerEvent(
        time: DateTime.now(),
        sessionId: sessionId,
        type: VideoTriggerEvents.minVideoOpen,
      );

  factory VideoTriggerEvent.singleChoice(
    String sessionId,
    String choiceCode,
  ) =>
      VideoTriggerEvent(
        time: DateTime.now(),
        type: VideoTriggerEvents.answer,
        sessionId: sessionId,
        args: <String, dynamic>{
          'answer': choiceCode,
        },
      );

  Map<String, dynamic> toMap() {
    return {
      'time': toDateServerFormat(time),
      'type': type.name,
      'args': args,
      'sessionId': sessionId,
    };
  }

  factory VideoTriggerEvent.fromMap(Map<String, dynamic> map) {
    return VideoTriggerEvent(
        time: DateTime.parse(map['time']),
        args: map['args'],
        sessionId: map['sessionId'],
        type: parseType(map['type']));
  }

  String toJson() => json.encode(toMap());

  factory VideoTriggerEvent.fromJson(String source) =>
      VideoTriggerEvent.fromMap(json.decode(source));

  static VideoTriggerEvents parseType(String data) {
    final search =
        VideoTriggerEvents.values.where((element) => element.name == data);
    if (search.isEmpty) {
      throw 'type not found';
    }
    return search.first;
  }
}
