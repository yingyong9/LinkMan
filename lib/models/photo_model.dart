import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class PhotoModel {
  final String urlPhoto;
  PhotoModel({
    required this.urlPhoto,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'urlPhoto': urlPhoto,
    };
  }

  factory PhotoModel.fromMap(Map<String, dynamic> map) {
    return PhotoModel(
      urlPhoto: (map['urlPhoto'] ?? '') as String,
    );
  }

  factory PhotoModel.fromJson(String source) => PhotoModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
