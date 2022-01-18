// import 'dart:convert';

class Author {
  String userName;
  String companyTitle;
  String? avatarUrl;

  Author({
    required this.userName,
    required this.companyTitle,
    this.avatarUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'companyTitle': companyTitle,
      'avatarUrl': avatarUrl,
    };
  }

  factory Author.fromMap(Map<String, dynamic> map) {
    return Author(
      userName: map['userName'] ?? '',
      companyTitle: map['companyTitle'] ?? '',
      avatarUrl: map['avatarUrl'],
    );
  }

  // String toJson() => json.encode(toMap());

  // factory Author.fromJson(String source) => Author.fromMap(json.decode(source));

  // @override
  // bool operator ==(Object other) {
  //   if (identical(this, other)) return true;

  //   return other is Author &&
  //       other.userName == userName &&
  //       other.companyTitle == companyTitle &&
  //       other.avatarUrl == avatarUrl;
  // }

  // @override
  // int get hashCode =>
  //     userName.hashCode ^ companyTitle.hashCode ^ avatarUrl.hashCode;
}
