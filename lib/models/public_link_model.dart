// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class PublicLinkModel {
  final String groupLink;
  final String namelink;
  final Timestamp timeAdd;
  final String uidAdd;
  final String urlLink;
  final String docIdOwner;
  PublicLinkModel({
    required this.groupLink,
    required this.namelink,
    required this.timeAdd,
    required this.uidAdd,
    required this.urlLink,
    required this.docIdOwner,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'groupLink': groupLink,
      'namelink': namelink,
      'timeAdd': timeAdd,
      'uidAdd': uidAdd,
      'urlLink': urlLink,
      'docIdOwner': docIdOwner,
    };
  }

  factory PublicLinkModel.fromMap(Map<String, dynamic> map) {
    return PublicLinkModel(
      groupLink: (map['groupLink'] ?? '') as String,
      namelink: (map['namelink'] ?? '') as String,
      timeAdd: (map['timeAdd']),
      uidAdd: (map['uidAdd'] ?? '') as String,
      urlLink: (map['urlLink'] ?? '') as String,
      docIdOwner: (map['docIdOwner'] ?? '') as String,
    );
  }

  factory PublicLinkModel.fromJson(String source) =>
      PublicLinkModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
