// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class ShowIconButton extends StatelessWidget {
  final IconData iconData;
  final Function() pressFunc;
  final Color? color;
  final double? size;
 

  const ShowIconButton({
    Key? key,
    required this.iconData,
    required this.pressFunc,
    this.color,
    this.size,
   
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
         iconSize: size ?? 24,
        onPressed: pressFunc,
        icon: Icon(
          iconData,
          color: color ?? Colors.white,
         
        ));
  }
}
