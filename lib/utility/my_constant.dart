import 'package:flutter/material.dart';

class MyConstant {
  static String appName = 'LINKMAN';

  static String routeAuthen = '/authen';
  static String rountMainHome = '/mainHome';

  static Color primary = const Color.fromARGB(255, 28, 111, 165);
  static Color light = const Color.fromARGB(255, 92, 92, 218);
  static Color dark = Colors.white;

  TextStyle h1Style() => TextStyle(
        fontSize: 36,
        color: dark,
        fontWeight: FontWeight.bold,
      );

  TextStyle h2Style() => TextStyle(
        fontSize: 18,
        color: dark,
        fontWeight: FontWeight.w700,
      );

  TextStyle h2WhiteStyle() => const TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      );

  TextStyle h3Style() => TextStyle(
        fontSize: 14,
        color: dark,
        fontWeight: FontWeight.normal,
      );

      TextStyle h3ActionStyle() => const TextStyle(
        fontSize: 14,
        color: Colors.lime,
        fontWeight: FontWeight.w500,
      );

  TextStyle h3WhiteStyle() => const TextStyle(
        fontSize: 14,
        color: Colors.white,
        fontWeight: FontWeight.normal,
      );
}
