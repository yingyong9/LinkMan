import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class FollowModel {
  final String uidClickFollow;
  final String token;
  FollowModel({
    required this.uidClickFollow,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uidClickFollow': uidClickFollow,
      'token': token,
    };
  }

  factory FollowModel.fromMap(Map<String, dynamic> map) {
    return FollowModel(
      uidClickFollow: (map['uidClickFollow'] ?? '') as String,
      token: (map['token'] ?? '') as String,
    );
  }

  factory FollowModel.fromJson(String source) => FollowModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
