// import 'dart:convert';

// import 'package:collection/collection.dart';

class ChoiceItem {
  String id;
  String text;

  ChoiceItem({
    required this.id,
    required this.text,
  });

  MapEntry toMap() {
    return MapEntry(id, text);
  }

  factory ChoiceItem.fromMap(Map<String, dynamic> map) {
    return ChoiceItem(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
    );
  }

  // String toJson() => json.encode(toMap());

  // factory ChoiceItem.fromJson(String source) =>
  //     ChoiceItem.fromMap(json.decode(source));

  // @override
  // String toString() => 'ChoiceItem(id: $id, text: $text)';

  // @override
  // bool operator ==(Object other) {
  //   if (identical(this, other)) return true;

  //   return other is ChoiceItem && other.id == id && other.text == text;
  // }

  // @override
  // int get hashCode => id.hashCode ^ text.hashCode;
}

class Survey {
  String question;
  List<ChoiceItem>? choices;

  Survey({
    required this.question,
    this.choices,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'choices': {for (var v in choices!) v.id: v.text},
    };
  }

  factory Survey.fromMap(Map<String, dynamic> map) {
    final List<ChoiceItem> choices = [];
    if (map.containsKey('choices')) {
      final choiceMap = map['choices'] as Map<String, String>;
      choiceMap.forEach(
        (key, value) => choices.add(ChoiceItem(id: key, text: value)),
      );
    }
    return Survey(
      question: map['question'] ?? '',
      choices: choices,
    );
  }

  // String toJson() => json.encode(toMap());

  // factory Survey.fromJson(String source) => Survey.fromMap(json.decode(source));

  // @override
  // String toString() => 'Survey(question: $question, choices: $choices)';

  // @override
  // bool operator ==(Object other) {
  //   if (identical(this, other)) return true;
  //   final listEquals = const DeepCollectionEquality().equals;

  //   return other is Survey &&
  //       other.question == question &&
  //       listEquals(other.choices, choices);
  // }

  // @override
  // int get hashCode => question.hashCode ^ choices.hashCode;
}
