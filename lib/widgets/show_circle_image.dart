// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class ShowCircleImage extends StatelessWidget {
  final String path;
  final double? radius;
  const ShowCircleImage({
    Key? key,
    required this.path,
    this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: 36,
      // height: 36,
      child: CircleAvatar(radius: radius ?? 25,
        backgroundImage: NetworkImage(path),
      ),
    );
  }
}
