// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class ShowImageAvatar extends StatelessWidget {
  final String urlImage;
  final double? size;
  const ShowImageAvatar({
    Key? key,
    required this.urlImage,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size ?? 24,
      backgroundImage: NetworkImage(urlImage),
    );
  }
}
