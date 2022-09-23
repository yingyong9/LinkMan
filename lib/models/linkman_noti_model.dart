// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class LinkManNotiModel {
  final Timestamp timePost;
  final String uidPost;
  final String urlImage;
  LinkManNotiModel({
    required this.timePost,
    required this.uidPost,
    required this.urlImage,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'timePost': timePost,
      'uidPost': uidPost,
      'urlImage': urlImage,
    };
  }

  factory LinkManNotiModel.fromMap(Map<String, dynamic> map) {
    return LinkManNotiModel(
      timePost: (map['timePost']),
      uidPost: (map['uidPost'] ?? '') as String,
      urlImage: (map['urlImage'] ?? '') as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory LinkManNotiModel.fromJson(String source) => LinkManNotiModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
