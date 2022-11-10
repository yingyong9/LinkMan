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
  final String keyRoom;
  final String linkContact;
  final String nameButtonLinkContact;
  final GeoPoint position;
  final String urlImage2;
  final String urlProduct;
  final bool friendOnly;
  final bool discovery;
  final String nameGroup;
  final String typeGroup;
  FastLinkModel({
    required this.urlImage,
    required this.detail,
    required this.linkId,
    required this.uidPost,
    required this.linkUrl,
    required this.timestamp,
    required this.detail2,
    required this.head,
    required this.keyRoom,
    required this.linkContact,
    required this.nameButtonLinkContact,
    required this.position,
    required this.urlImage2,
    required this.urlProduct,
    required this.friendOnly,
    required this.discovery,
    required this.nameGroup,
    required this.typeGroup,
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
      'keyRoom': keyRoom,
      'linkContact': linkContact,
      'nameButtonLinkContact': nameButtonLinkContact,
      'position': position,
      'urlImage2': urlImage2,
      'urlProduct': urlProduct,
      'friendOnly': friendOnly,
      'discovery': discovery,
      'nameGroup': nameGroup,
      'typeGroup': typeGroup,
    };
  }

  factory FastLinkModel.fromMap(Map<String, dynamic> map) {
    return FastLinkModel(
      urlImage: (map['urlImage'] ?? '') as String,
      detail: (map['detail'] ?? '') as String,
      linkId: (map['linkId'] ?? '') as String,
      uidPost: (map['uidPost'] ?? '') as String,
      linkUrl: (map['linkUrl'] ?? '') as String,
      timestamp: (map['timestamp'] ),
      detail2: (map['detail2'] ?? '') as String,
      head: (map['head'] ?? '') as String,
      keyRoom: (map['keyRoom'] ?? '') as String,
      linkContact: (map['linkContact'] ?? '') as String,
      nameButtonLinkContact: (map['nameButtonLinkContact'] ?? '') as String,
      position: (map['position'] ?? const GeoPoint(0, 0) ),
      urlImage2: (map['urlImage2'] ?? '') as String,
      urlProduct: (map['urlProduct'] ?? '') as String,
      friendOnly: (map['friendOnly'] ?? false) as bool,
      discovery: (map['discovery'] ?? false) as bool,
      nameGroup: (map['nameGroup'] ?? '') as String,
      typeGroup: (map['typeGroup'] ?? '') as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory FastLinkModel.fromJson(String source) =>
      FastLinkModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
