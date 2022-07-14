import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class LinkFriendModel {
  final String uidLinkFriend;
  LinkFriendModel({
    required this.uidLinkFriend,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uidLinkFriend': uidLinkFriend,
    };
  }

  factory LinkFriendModel.fromMap(Map<String, dynamic> map) {
    return LinkFriendModel(
      uidLinkFriend: (map['uidLinkFriend'] ?? '') as String,
    );
  }

  factory LinkFriendModel.fromJson(String source) => LinkFriendModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
