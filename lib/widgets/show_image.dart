// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class ShowImage extends StatelessWidget {
  final String? path;
  final double? width;
  const ShowImage({
    Key? key,
    this.path,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width ?? 125,
      child: Image.asset(path ?? 'images/avatar.png'),
    );
  }
}
