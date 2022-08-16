import 'package:flutter/material.dart';

class MyStyle {
  static Color bgColor = Colors.white;
  static Color dark = Colors.black;

  BoxDecoration curveBorderBox({double? curve, Color? color}) => BoxDecoration(
        border: Border.all(color: color ?? Colors.black),
        borderRadius: BorderRadius.circular(
          curve ?? 10,
        ),
      );

  TextStyle h1Style() => TextStyle(
        fontSize: 36,
        color: dark,
        fontWeight: FontWeight.bold,
        fontFamily: 'Sarabun',
      );

  TextStyle h2Style({Color? color}) => TextStyle(
        fontSize: 16,
        color: color ?? dark,
        fontWeight: FontWeight.w700,
        fontFamily: 'Sarabun',
      );

     

  TextStyle h3Style() => TextStyle(
        fontSize: 14,
        color: dark,
        fontWeight: FontWeight.normal,
        fontFamily: 'Sarabun',
      );

  TextStyle h3ActiveStyle() => TextStyle(
        fontSize: 14,
        color: dark,
        fontWeight: FontWeight.w500,
        fontFamily: 'Sarabun',
      );
}
