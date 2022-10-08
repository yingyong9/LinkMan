// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class ShowImageIconButton extends StatelessWidget {
  final String path;
  final Function() pressFunc;
  final double? size;
  const ShowImageIconButton({
    Key? key,
    required this.path,
    required this.pressFunc,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 36,
      height: size ?? 36,
      child: InkWell(
        onTap: pressFunc,
        child: Image.asset(path),
      ),
    );
  }
}
