import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class LinkModel {
  final String nameLink;
  final String urlLink;
  final String groupLink;
  LinkModel({
    required this.nameLink,
    required this.urlLink,
    required this.groupLink,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nameLink': nameLink,
      'urlLink': urlLink,
      'groupLink': groupLink,
    };
  }

  factory LinkModel.fromMap(Map<String, dynamic> map) {
    return LinkModel(
      nameLink: (map['nameLink'] ?? '') as String,
      urlLink: (map['urlLink'] ?? '') as String,
      groupLink: (map['groupLink'] ?? '') as String,
    );
  }

  factory LinkModel.fromJson(String source) => LinkModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
