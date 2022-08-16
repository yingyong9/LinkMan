import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class CategoryRoomModel {
  final int item;
  final String category;
  final int room;
  CategoryRoomModel({
    required this.item,
    required this.category,
    required this.room,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'item': item,
      'category': category,
      'room': room,
    };
  }

  factory CategoryRoomModel.fromMap(Map<String, dynamic> map) {
    return CategoryRoomModel(
      item: (map['item'] ?? 0) as int,
      category: (map['category'] ?? '') as String,
      room: (map['room'] ?? 0) as int,
    );
  }

  factory CategoryRoomModel.fromJson(String source) => CategoryRoomModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
