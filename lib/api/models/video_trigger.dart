import 'dart:convert';
import 'dart:typed_data';

import 'author.dart';
import 'survey.dart';

enum PalVideos {
  survey,
  // min_to_big_video, //VNEXT
}

class PalVideoTrigger {
  String? eventLogId;
  String videoId;
  DateTime creationDate;

  String videoUrl;
  String videoThumbUrl;
  String imgThumbUrl;

  // PalVideos type;
  Author author;
  Survey? survey;

  PalVideoTrigger({
    required this.eventLogId,
    required this.videoId,
    required this.creationDate,
    required this.videoUrl,
    required this.videoThumbUrl,
    required this.imgThumbUrl,

    // required this.type,
    required this.author,
    this.survey,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventLogId': eventLogId,
      'videoId': videoId,
      'creationDate': creationDate.toIso8601String(),
      'videoUrl': videoUrl,
      'videoThumbUrl': videoThumbUrl,
      'imgThumbUrl': imgThumbUrl,
      // 'type': type.name,
      'author': author.toMap(),
      'survey': survey?.toMap(),
    };
  }

  factory PalVideoTrigger.fromMap(Map<String, dynamic> map) {
    return PalVideoTrigger(
      eventLogId: map['eventLogId'] ?? '',
      videoId: map['videoId'] ?? '',
      creationDate: DateTime.parse(map['creationDate']),
      videoUrl: map['videoUrl'] ?? '',
      videoThumbUrl: map['videoThumbUrl'] ?? '',
      imgThumbUrl: map['imgThumbUrl'] ?? '',
      // type: parseType(map['type']),
      author: Author(
        userName: map['videoSpeakerName'] ?? '',
        companyTitle: map['videoSpeakerRole'] ?? '',
      ),
      survey: map['survey'] != null ? Survey.fromMap(map['survey']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PalVideoTrigger.fromJson(String source) {
    return PalVideoTrigger.fromMap(json.decode(source));
  }

  factory PalVideoTrigger.fromJsonBytes(Uint8List source) {
    return PalVideoTrigger.fromMap(json.decode(utf8.decode(source)));
  }

  static PalVideos parseType(String data) {
    final search = PalVideos.values.where((element) => element.name == data);
    if (search.isEmpty) {
      throw 'video type not found';
    }
    return search.first;
  }

  bool get isSurveyType => survey != null;

  bool get isTalkType => survey == null;
}
