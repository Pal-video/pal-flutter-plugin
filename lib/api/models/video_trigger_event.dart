import 'dart:convert';

enum VideoTriggerEvents {
  video_skip,
  min_video_open,
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

  VideoTriggerEvent({
    required this.time,
    required this.type,
  });

  VideoTriggerEvent copyWith({
    String? videoId,
    DateTime? time,
    VideoTriggerEvents? type,
  }) {
    return VideoTriggerEvent(
      time: time ?? this.time,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time.millisecondsSinceEpoch,
      'type': type.name,
    };
  }

  factory VideoTriggerEvent.fromMap(Map<String, dynamic> map) {
    return VideoTriggerEvent(
        time: DateTime.fromMillisecondsSinceEpoch(map['time']),
        type: parseType(map['type']));
  }

  String toJson() => json.encode(toMap());

  factory VideoTriggerEvent.fromJson(String source) =>
      VideoTriggerEvent.fromMap(json.decode(source));

  @override
  String toString() => 'VideoTriggerEvent(time: $time)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VideoTriggerEvent && other.time == time;
  }

  @override
  int get hashCode => type.hashCode ^ time.hashCode;

  static VideoTriggerEvents parseType(String data) {
    final search =
        VideoTriggerEvents.values.where((element) => element.name == data);
    if (search.isEmpty) {
      throw 'type not found';
    }
    return search.first;
  }
}
