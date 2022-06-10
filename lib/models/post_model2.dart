// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel2 {
  final String uidPost;
  final List<String> urlPaths;
  final List<Map<String, dynamic>> link;
  final String nameButton;
  final String name;
  final Timestamp timePost;
  final List<String> nameLink;
  PostModel2({
    required this.uidPost,
    required this.urlPaths,
    required this.link,
    required this.nameButton,
    required this.name,
    required this.timePost,
    required this.nameLink,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uidPost': uidPost,
      'urlPaths': urlPaths,
      'link': link,
      'nameButton': nameButton,
      'name': name,
      'timePost': timePost,
      'nameLink': nameLink,
    };
  }

  factory PostModel2.fromMap(Map<String, dynamic> map) {
    return PostModel2(
      uidPost: (map['uidPost'] ?? '') as String,
      urlPaths: List<String>.from(map['urlPaths']),
      link: List<Map<String, dynamic>>.from(map['link'] ?? [{'link1', 'https://www.google.co.th'}]),
      nameButton: (map['nameButton'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      timePost: (map['timePost']),
      nameLink: List<String>.from(
          (map['nameLink'] ?? const <String>[]) as List<String>),
    );
  }

  factory PostModel2.fromJson(String source) =>
      PostModel2.fromMap(json.decode(source) as Map<String, dynamic>);
}

// return PostModel2(
//       uidPost: (map['uidPost'] ?? '') as String,
//       urlPaths: List<String>.from(map['urlPaths']),
//       link: List<Map<String, dynamic>>.from(map['link']),
//       nameButton: (map['nameButton'] ?? '') as String,
//       name: (map['name'] ?? '') as String,
//       timePost: (map['timePost']),
//       nameLink: List<String>.from(
//           (map['nameLink'] ?? const <String>[]) as List<String>),
//     );


 
