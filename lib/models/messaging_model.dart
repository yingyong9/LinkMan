import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class MessageingModel {
  final List<String> doubleMessages;
  MessageingModel({
    required this.doubleMessages,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'doubleMessages': doubleMessages,
    };
  }

  factory MessageingModel.fromMap(Map<String, dynamic> map) {
    return MessageingModel(
      doubleMessages: List<String>.from(map['doubleMessages'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageingModel.fromJson(String source) => MessageingModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
