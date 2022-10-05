import 'package:flutter/material.dart';

class MyStyle {
  static Color bgColor = Colors.white;
  static Color dark = Colors.black;
  static Color green = const Color.fromARGB(255, 64, 98, 23);
  static Color green2 =const Color.fromARGB(255, 162, 226, 85);
  static Color red = const Color.fromARGB(255, 231, 56, 56);

  BoxDecoration bgCircleBlack() => BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
      );

  BoxDecoration bgCircleGrey() => BoxDecoration(
        color: Colors.grey.withOpacity(0.20),
        borderRadius: BorderRadius.circular(30),
      );

  BoxDecoration curveBorderBox({double? curve, Color? color}) => BoxDecoration(
        border: Border.all(color: color ?? dark),
        borderRadius: BorderRadius.circular(
          curve ?? 10,
        ),
      );

  TextStyle h1Style({Color? color}) => TextStyle(
        fontSize: 36,
        color: color ?? dark,
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

  TextStyle h3GreenStyle() => TextStyle(
        fontSize: 14,
        color: green,
        fontWeight: FontWeight.normal,
        fontFamily: 'Sarabun',
      );

      TextStyle h3GreenBoldStyle() => TextStyle(
        fontSize: 14,
        color: green2,
        fontWeight: FontWeight.bold,
        fontFamily: 'Sarabun',
      );

  TextStyle h3GreyStyle() =>  TextStyle(
        fontSize: 14,
        color: Colors.grey.shade300,
        fontWeight: FontWeight.bold,
        fontFamily: 'Sarabun',
      );

  TextStyle h3RedStyle() => TextStyle(
        fontSize: 14,
        color: red,
        fontWeight: FontWeight.normal,
        fontFamily: 'Sarabun',
      );

  TextStyle h3WhiteStyle() => const TextStyle(
        fontSize: 14,
        color: Colors.white,
        fontWeight: FontWeight.normal,
        fontFamily: 'Sarabun',
      );

  TextStyle h3WhiteBoldStyle() => const TextStyle(
        fontSize: 14,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontFamily: 'Sarabun',
      );

  TextStyle h3ActiveStyle() => TextStyle(
        fontSize: 14,
        color: dark,
        fontWeight: FontWeight.w500,
        fontFamily: 'Sarabun',
      );
}
