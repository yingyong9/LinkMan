import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class FastLinkModel {
  final String urlImage;
  final String detail;
  final String linkId;
  final String uidPost;
  final String linkUrl;
  final Timestamp timestamp;
  final String detail2;
  final String head;
  final String urlSong;
  final String keyRoom;
  final String linkContact;
  final String nameButtonLinkContact;
  final GeoPoint position;

  FastLinkModel({
    required this.urlImage,
    required this.detail,
    required this.linkId,
    required this.uidPost,
    required this.linkUrl,
    required this.timestamp,
    required this.detail2,
    required this.head,
    required this.urlSong,
    required this.keyRoom,
    required this.linkContact,
    required this.nameButtonLinkContact,
    required this.position,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'urlImage': urlImage,
      'detail': detail,
      'linkId': linkId,
      'uidPost': uidPost,
      'linkUrl': linkUrl,
      'timestamp': timestamp,
      'detail2': detail2,
      'head': head,
      'urlSong': urlSong,
      'keyRoom': keyRoom,
      'linkContact': linkContact,
      'nameButtonLinkContact': nameButtonLinkContact,
      'position': position,
    };
  }

  factory FastLinkModel.fromMap(Map<String, dynamic> map) {
    return FastLinkModel(
      urlImage: (map['urlImage'] ?? '') as String,
      detail: (map['detail'] ?? '') as String,
      linkId: (map['linkId'] ?? '') as String,
      uidPost: (map['uidPost'] ?? '') as String,
      linkUrl: (map['linkUrl'] ?? '') as String,
      timestamp: (map['timestamp']),
      detail2: (map['detail2'] ?? '') as String,
      head: (map['head'] ?? '') as String,
      urlSong: (map['urlSong'] ?? '') as String,
      keyRoom: (map['keyRoom'] ?? '') as String,
      linkContact: (map['linkContact'] ?? '') as String,
      nameButtonLinkContact: (map['nameButtonLinkContact'] ?? '') as String,
      position: (map['position'] ?? const GeoPoint(0, 0)),
    );
  }

  factory FastLinkModel.fromJson(String source) =>
      FastLinkModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
