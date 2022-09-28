// ignore_for_file: avoid_print

import 'dart:io';

import 'package:admanyout/states/authen.dart';
import 'package:admanyout/states/main_home.dart';
import 'package:admanyout/states/search_shortcode.dart';
import 'package:admanyout/states2/grand_home.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> map = {
  MyConstant.routeAuthen: (context) => const Authen(),
  MyConstant.rountMainHome: (context) => const MainHome(),
  '/searchShortCode': (context) => const SearchShortCode(),
  '/grandHome': (context) => const GrandHome(),
};

//update 4juny

String? initial;

Future<void> main() async {
  HttpOverrides.global = MyHttpOverride();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().then((value) {
    initial = '/grandHome';
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays([]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: map,
      initialRoute: initial,
      theme: ThemeData(
          primarySwatch: Colors.grey,
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: MyStyle.bgColor,
            foregroundColor: MyStyle.dark,
          )),
    );
  }
}

class MyHttpOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}
