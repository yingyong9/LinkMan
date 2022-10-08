// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class LinkManNotiModel {
  final Timestamp timePost;
  final String uidPost;
  final String urlImage0;
  final String urlImage1;
  final bool friend;
  final bool discovery;
  final GeoPoint geoPoint;
  LinkManNotiModel({
    required this.timePost,
    required this.uidPost,
    required this.urlImage0,
    required this.urlImage1,
    required this.friend,
    required this.discovery,
    required this.geoPoint,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'timePost': timePost,
      'uidPost': uidPost,
      'urlImage0': urlImage0,
      'urlImage1': urlImage1,
      'friend': friend,
      'discovery': discovery,
      'geoPoint': geoPoint,
    };
  }

  factory LinkManNotiModel.fromMap(Map<String, dynamic> map) {
    return LinkManNotiModel(
      timePost: (map['timePost']),
      uidPost: (map['uidPost'] ?? '') as String,
      urlImage0: (map['urlImage0'] ?? '') as String,
      urlImage1: (map['urlImage1'] ?? '') as String,
      friend: (map['friend'] ?? false) as bool,
      discovery: (map['discovery'] ?? false) as bool,
      geoPoint: (map['geoPoint'] ?? const GeoPoint(0, 0)),
    );
  }

  String toJson() => json.encode(toMap());

  factory LinkManNotiModel.fromJson(String source) => LinkManNotiModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
