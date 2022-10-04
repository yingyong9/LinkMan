// ignore_for_file: avoid_print

import 'package:admanyout/states/search_shortcode.dart';
import 'package:admanyout/states2/friend.dart';
import 'package:admanyout/states2/live_video.dart';
import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class GrandHome extends StatefulWidget {
  const GrandHome({Key? key}) : super(key: key);

  @override
  State<GrandHome> createState() => _GrandHomeState();
}

class _GrandHomeState extends State<GrandHome> {
  var bodys = <Widget>[];
  var tabs = <Widget>[];
  var titles = <String>[
    'Freind',
    'Discovery',
    'Live',
  ];

  @override
  void initState() {
    super.initState();

    grandCheckUser();
    setupTabNavigator();
    setupNoti();
  }

  Future<void> setupNoti() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String? token = await firebaseMessaging.getToken();
    print('##27sep token ===> $token');

    FirebaseMessaging.onMessage.listen((event) {
      print('##27sep title ==> ${event.notification!.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {});
  }

  Future<void> grandCheckUser() async {
    var result = await MyFirebase().checkLogin();
  }

  void setupTabNavigator() {
    bodys.add(const Friend());
    bodys.add(const SearchShortCode());
    bodys.add(const LiveVideo());

    for (var element in titles) {
      tabs.add(Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ShowText(
          label: element,
          textStyle: MyStyle().h2Style(color: MyStyle.bgColor),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          initialIndex: 1,
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: MyStyle.dark,
              // leading: ShowIconButton(
              //   color: MyStyle.bgColor,
              //   iconData: Icons.add_box_outlined,
              //   size: 36,
              //   pressFunc: () {},
              // ),
              centerTitle: true,
              title: ShowText(
                label: 'LinkMan.',
                textStyle: MyStyle().h1Style(color: MyStyle.bgColor),
              ),
              bottom: TabBar(tabs: tabs),
              // actions: [
              //   ShowIconButton(
              //     color: MyStyle.bgColor,
              //     iconData: Icons.more_vert,
              //     pressFunc: () async {
              //       bool result = await MyFirebase().checkLogin();
              //       if (result) {
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) => const Setting(),
              //             ));
              //       } else {
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) => const Authen(),
              //             ));
              //       }
              //     },
              //   )
              // ],
            ),
            body: TabBarView(children: bodys),
          ),
        ),
      ),
    );
  }
}
