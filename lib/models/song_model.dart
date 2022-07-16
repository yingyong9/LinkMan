import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class SongModel {
  final String url;
  SongModel({
    required this.url,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'url': url,
    };
  }

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      url: (map['url'] ?? '') as String,
    );
  }

  factory SongModel.fromJson(String source) => SongModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
