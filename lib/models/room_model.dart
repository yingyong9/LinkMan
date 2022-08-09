// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  final String idRoom;
  final String linkContact;
  final String linkRoom;
  final String nameRoom;
  final String password;
  final Timestamp timeDateAdd;
  final String uidOwner;
  final String urlImage;
  final bool usePassword;
  RoomModel({
    required this.idRoom,
    required this.linkContact,
    required this.linkRoom,
    required this.nameRoom,
    required this.password,
    required this.timeDateAdd,
    required this.uidOwner,
    required this.urlImage,
    required this.usePassword,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idRoom': idRoom,
      'linkContact': linkContact,
      'linkRoom': linkRoom,
      'nameRoom': nameRoom,
      'password': password,
      'timeDateAdd': timeDateAdd,
      'uidOwner': uidOwner,
      'urlImage': urlImage,
      'usePassword': usePassword,
    };
  }

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      idRoom: (map['idRoom'] ?? '') as String,
      linkContact: (map['linkContact'] ?? '') as String,
      linkRoom: (map['linkRoom'] ?? '') as String,
      nameRoom: (map['nameRoom'] ?? '') as String,
      password: (map['password'] ?? '') as String,
      timeDateAdd: (map['timeDateAdd']),
      uidOwner: (map['uidOwner'] ?? '') as String,
      urlImage: (map['urlImage'] ?? '') as String,
      usePassword: (map['usePassword'] ?? false) as bool,
    );
  }

  factory RoomModel.fromJson(String source) => RoomModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
