// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class SosPostModel {
  final String post;
  final String uidPost;
  final Timestamp timePost;
  final String? urlImagePost;
  SosPostModel({
    required this.post,
    required this.uidPost,
    required this.timePost,
    this.urlImagePost,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'post': post,
      'uidPost': uidPost,
      'timePost': timePost,
      'urlImagePost': urlImagePost,
    };
  }

  factory SosPostModel.fromMap(Map<String, dynamic> map) {
    return SosPostModel(
      post: (map['post'] ?? '') as String,
      uidPost: (map['uidPost'] ?? '') as String,
      timePost: (map['timePost']),
      urlImagePost: map['urlImagePost'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SosPostModel.fromJson(String source) =>
      SosPostModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
