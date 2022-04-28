// ignore_for_file: avoid_print

import 'package:admanyout/states/authen.dart';
import 'package:admanyout/states/main_home.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> map = {
  MyConstant.routeAuthen: (context) => const Authen(),
  MyConstant.rountMainHome: (context) => const MainHome(),
};

String? initial;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().then((value) {
    // print('firebase initial Successs');
    FirebaseAuth.instance.authStateChanges().listen((event) {
      if (event == null) {
        initial = MyConstant.routeAuthen;
      } else {
        initial = MyConstant.rountMainHome;
      }
      runApp(const MyApp());
    });
  });
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      routes: map,
      initialRoute: initial,
    );
  }
}
