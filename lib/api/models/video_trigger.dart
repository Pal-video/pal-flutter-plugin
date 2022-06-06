import 'dart:convert';

import 'package:pal/api/models/author.dart';
import 'package:pal/api/models/survey.dart';

enum PalVideos {
  survey,
  min_to_big_video,
}

class PalVideoTrigger {
  String id;
  String video240pUrl;
  String video480pUrl;
  String video720pUrl;
  // PalVideos type;
  Author author;
  Survey? survey;

  PalVideoTrigger({
    required this.id,
    required this.video240pUrl,
    required this.video480pUrl,
    required this.video720pUrl,
    // required this.type,
    required this.author,
    this.survey,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'video240pUrl': video240pUrl,
      'video480pUrl': video480pUrl,
      'video720pUrl': video720pUrl,
      // 'type': type.name,
      'author': author.toMap(),
      'survey': survey?.toMap(),
    };
  }

  factory PalVideoTrigger.fromMap(Map<String, dynamic> map) {
    return PalVideoTrigger(
      id: map['id'] ?? '',
      video240pUrl: map['video240pUrl'] ?? '',
      video480pUrl: map['video480pUrl'] ?? '',
      video720pUrl: map['video720pUrl'] ?? '',
      // type: parseType(map['type']),
      author: Author.fromMap(map['author']),
      survey: map['survey'] != null ? Survey.fromMap(map['survey']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PalVideoTrigger.fromJson(String source) =>
      PalVideoTrigger.fromMap(json.decode(source));

  // @override
  // bool operator ==(Object other) {
  //   if (identical(this, other)) return true;

  //   return other is PalVideoTrigger &&
  //       other.id == id &&
  //       other.video240pUrl == video240pUrl &&
  //       other.video480pUrl == video480pUrl &&
  //       other.video720pUrl == video720pUrl &&
  //       other.type == type &&
  //       other.author == author &&
  //       other.survey == survey;
  // }

  // @override
  // int get hashCode {
  //   return id.hashCode ^
  //       video240pUrl.hashCode ^
  //       video480pUrl.hashCode ^
  //       video720pUrl.hashCode ^
  //       type.hashCode ^
  //       author.hashCode ^
  //       survey.hashCode;
  // }

  static PalVideos parseType(String data) {
    final search = PalVideos.values.where((element) => element.name == data);
    if (search.isEmpty) {
      throw 'video type not found';
    }
    return search.first;
  }

  // PalVideoTrigger copyWith({
  //   String? id,
  //   String? video240pUrl,
  //   String? video480pUrl,
  //   String? video720pUrl,
  //   PalVideos? type,
  //   Author? author,
  //   Survey? survey,
  // }) {
  //   return PalVideoTrigger(
  //     id: id ?? this.id,
  //     video240pUrl: video240pUrl ?? this.video240pUrl,
  //     video480pUrl: video480pUrl ?? this.video480pUrl,
  //     video720pUrl: video720pUrl ?? this.video720pUrl,
  //     type: type ?? this.type,
  //     author: author ?? this.author,
  //     survey: survey ?? this.survey,
  //   );
  // }
}
