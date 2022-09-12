// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class ShowImageIconButton extends StatelessWidget {
  final String path;
  final Function() pressFunc;
  const ShowImageIconButton({
    Key? key,
    required this.path,
    required this.pressFunc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: InkWell(
        onTap: pressFunc,
        child: Image.asset(path),
      ),
    );
  }
}
