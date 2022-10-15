// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class SosModel {
  final GeoPoint sosGeopoint;
  final Timestamp timeSos;
  final String uidSos;
  final String urlBig;
  final String urlSmall;
  final String textHelp;
  SosModel({
    required this.sosGeopoint,
    required this.timeSos,
    required this.uidSos,
    required this.urlBig,
    required this.urlSmall,
    required this.textHelp,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sosGeopoint': sosGeopoint,
      'timeSos': timeSos,
      'uidSos': uidSos,
      'urlBig': urlBig,
      'urlSmall': urlSmall,
      'textHelp': textHelp,
    };
  }

  factory SosModel.fromMap(Map<String, dynamic> map) {
    return SosModel(
      sosGeopoint: (map['sosGeopoint'] ?? const GeoPoint(0, 0)),
      timeSos: (map['timeSos']),
      uidSos: (map['uidSos'] ?? '') as String,
      urlBig: (map['urlBig'] ?? '') as String,
      urlSmall: (map['urlSmall'] ?? '') as String,
      textHelp: (map['textHelp'] ?? '') as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SosModel.fromJson(String source) =>
      SosModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
