import 'package:flutter/material.dart';

class MyConstant {
  static String appName = 'LINKMAN';

  static String routeAuthen = '/authen';
  static String rountMainHome = '/mainHome';

  static Color primary = const Color.fromARGB(255, 28, 111, 165);
  static Color light = const Color.fromARGB(255, 92, 92, 218);
  static Color dark = Colors.white;

  static String urlLogo =
      'https://firebasestorage.googleapis.com/v0/b/adman-87dfd.appspot.com/o/avatar%2Flogo.png?alt=media&token=64767fbd-371f-4aaa-8854-ba839759751e';

  BoxDecoration curveBorderBox() => BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(10),
      );

  TextStyle h1Style() => TextStyle(
        fontSize: 36,
        color: dark,
        fontWeight: FontWeight.bold,
        fontFamily: 'Sarabun',
      );

  TextStyle h1GreenStyle() => const TextStyle(
        fontSize: 36,
        color: Color.fromARGB(255, 71, 199, 75),
        fontWeight: FontWeight.bold,
        
      );

  TextStyle h2Style() => TextStyle(
        fontSize: 18,
        color: dark,
        fontWeight: FontWeight.w700,
        fontFamily: 'Sarabun',
      );

      TextStyle h2BlackStyle() => const TextStyle(
        fontSize: 18,
        color: Color.fromARGB(255, 230, 24, 24),
        fontWeight: FontWeight.w700,
        fontFamily: 'Sarabun',
      );

       TextStyle h2BlackBBBStyle() => const TextStyle(
        fontSize: 18,
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontFamily: 'Sarabun',
      );

  TextStyle h2redStyle() => const TextStyle(
        fontSize: 30,
        color: Color.fromARGB(255, 236, 48, 34),
        fontWeight: FontWeight.w700,
        fontFamily: 'Sarabun',
      );

  TextStyle h2v2Style() => TextStyle(
        fontSize: 30,
        color: dark,
        fontWeight: FontWeight.w700,
        fontFamily: 'Sarabun',
      );

  TextStyle h2WhiteStyle() => const TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontFamily: 'Sarabun',
      );

  TextStyle h2WhiteBigStyle() => const TextStyle(
        fontSize: 24,
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontFamily: 'Sarabun',
      );

  TextStyle h3Style() => TextStyle(
        fontSize: 14,
        color: dark,
        fontWeight: FontWeight.normal,
        fontFamily: 'Sarabun',
      );

     

  TextStyle h3BlackStyle() => const TextStyle(
        fontSize: 14,
        color: Colors.black,
        fontWeight: FontWeight.normal,
        fontFamily: 'Sarabun',
      );

  TextStyle h3ActionStyle() => const TextStyle(
        fontSize: 14,
        color: Colors.lime,
        fontWeight: FontWeight.w500,
        fontFamily: 'Sarabun',
      );

      TextStyle h3ActionPinkStyle() => const TextStyle(
        fontSize: 14,
        color: Color.fromARGB(255, 225, 47, 148),
        fontWeight: FontWeight.w500,
        fontFamily: 'Sarabun',
      );

  TextStyle h3WhiteStyle() => const TextStyle(
        fontSize: 14,
        color: Colors.white,
        fontWeight: FontWeight.normal,
        fontFamily: 'Sarabun',
      );

       TextStyle h3RedStyle() => const TextStyle(
        fontSize: 14,
        color: Color.fromARGB(255, 228, 36, 36),
        fontWeight: FontWeight.normal,
        fontFamily: 'Sarabun',
      );
}
