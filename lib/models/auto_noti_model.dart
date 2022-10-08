import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AutoNotiModel {
  final String docIdSendNoti;
  final Timestamp timeSend;
  AutoNotiModel({
    required this.docIdSendNoti,
    required this.timeSend,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'docIdSendNoti': docIdSendNoti,
      'timeSend': timeSend,
    };
  }

  factory AutoNotiModel.fromMap(Map<String, dynamic> map) {
    return AutoNotiModel(
      docIdSendNoti: (map['docIdSendNoti'] ?? '') as String,
      timeSend: (map['timeSend']),
    );
  }

  String toJson() => json.encode(toMap());

  factory AutoNotiModel.fromJson(String source) => AutoNotiModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
