import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class MemberModel {
  final String uidMember;
  MemberModel({
    required this.uidMember,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uidMember': uidMember,
    };
  }

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      uidMember: (map['uidMember'] ?? '') as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory MemberModel.fromJson(String source) => MemberModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
