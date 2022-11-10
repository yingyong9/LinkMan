// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class WidgetImageInternet extends StatelessWidget {
  final String path;
  final double? width;
  final double? hight;
  final BoxFit? boxFit;
  final Function()? pressFunc;
  const WidgetImageInternet({
    Key? key,
    required this.path,
    this.width,
    this.hight,
    this.boxFit,
    this.pressFunc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: pressFunc,
      child: Image.network(
        path,
        width: width,
        height: hight,
        fit: boxFit ?? BoxFit.contain,
      ),
    );
  }
}
