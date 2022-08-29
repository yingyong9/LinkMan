// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String comment;
  final Timestamp timeComment;
  final String uidComment;
  CommentModel({
    required this.comment,
    required this.timeComment,
    required this.uidComment,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'comment': comment,
      'timeComment': timeComment,
      'uidComment': uidComment,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      comment: (map['comment'] ?? '') as String,
      timeComment: (map['timeComment'] ),
      uidComment: (map['uidComment'] ?? '') as String,
    );
  }

  factory CommentModel.fromJson(String source) => CommentModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
