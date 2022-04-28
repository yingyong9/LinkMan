// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class SpecialModel {
  final String key;
  final Timestamp expire;
  SpecialModel({
    required this.key,
    required this.expire,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'key': key,
      'expire': expire,
    };
  }

  factory SpecialModel.fromMap(Map<String, dynamic> map) {
    return SpecialModel(
      key: (map['key'] ?? '') as String,
      expire: (map['expire']),
    );
  }

  factory SpecialModel.fromJson(String source) => SpecialModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
