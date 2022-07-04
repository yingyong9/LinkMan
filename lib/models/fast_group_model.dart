import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class FastGroupModel {
  final String nameGroup;
  FastGroupModel({
    required this.nameGroup,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nameGroup': nameGroup,
    };
  }

  factory FastGroupModel.fromMap(Map<String, dynamic> map) {
    return FastGroupModel(
      nameGroup: (map['nameGroup'] ?? '') as String,
    );
  }

  factory FastGroupModel.fromJson(String source) => FastGroupModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
