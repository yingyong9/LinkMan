// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class ShowCircleImage extends StatelessWidget {
  final String path;
  final double? radius;
  final Function()? pressFunc;
  const ShowCircleImage({
    Key? key,
    required this.path,
    this.radius,
    this.pressFunc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: pressFunc,
      child: CircleAvatar(
        radius: radius ?? 25,
        backgroundImage: NetworkImage(path),
      ),
    );
  }
}
