// ignore_for_file: avoid_print

import 'dart:math';

import 'package:admanyout/models/auto_noti_model.dart';
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/states/noti_fast_photo.dart';
import 'package:admanyout/states/search_shortcode.dart';
import 'package:admanyout/states2/friend.dart';
import 'package:admanyout/states2/live_video.dart';
import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  var user = FirebaseAuth.instance.currentUser;
  
  bool firstOpen = false;

  @override
  void initState() {
    super.initState();

    grandCheckUser();
    setupTabNavigator();
    setupNoti();
    autoSendNoti();
  }

  Future<void> autoSendNoti() async {
   

    DateTime dateTime = DateTime.now();
    DateFormat dateFormat = DateFormat('ddMMMyyyy');
    String docIdAutoNoti = dateFormat.format(dateTime);

    await FirebaseFirestore.instance
        .collection('user')
        .get()
        .then((value) async {
      for (var element in value.docs) {
        UserModel userModel = UserModel.fromMap(element.data());

        String tokenSend = userModel.token ?? '';
        // print('##8oct tokenSend ==> $tokenSend');

        await FirebaseFirestore.instance
            .collection('autoNoti')
            .doc(docIdAutoNoti)
            .get()
            .then((value) async {
          if (value.data() == null) {
            firstOpen = true;
            AutoNotiModel autoNotiModel = AutoNotiModel(
                docIdSendNoti: user!.uid,
                timeSend: Timestamp.fromDate(dateTime));
            await FirebaseFirestore.instance
                .collection('autoNoti')
                .doc(docIdAutoNoti)
                .set(autoNotiModel.toMap())
                .then((value) => print('##8oct create doc Success'));
          }
        });

        if ((tokenSend.isNotEmpty) && firstOpen) {
          print('##8oct tokenSend ==> $tokenSend');
          String title = 'ถ่ายรูป บอกให้โลกรู้';
          String body = 'คุณมีเวลา 2 นาที';

          String path =
              'https://www.androidthai.in.th/flutter/linkman/linkManNoti.php?isAdd=true&token=$tokenSend&title=$title&body=$body';
          await Dio().get(path).then((value) {
            print('##8oct SentNoti Success');
          });
        }
      }

      print('##8oct ขนาดของ User ==> ${value.docs.length}');
      print('##8oct docIdAutoNoti ==> $docIdAutoNoti');
    }).catchError((onError) {
      print('#7oct error ==>> $onError');
    });
  }

  Future<void> setupNoti() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String? token = await firebaseMessaging.getToken();
    print('##27sep token ===> $token');

    if (token != null) {
      await MyFirebase().updateToken(uid: user!.uid, token: token);
    }

    FirebaseMessaging.onMessage.listen((event) {
      String? title = event.notification!.title;
      String? body = event.notification!.body;
      MyDialog(context: context).normalActionDilalog(
        title: title!,
        message: body!,
        label: 'ถ่ายรูป ร่วมสนุกกับ เพื่อนๆของคุณ',
        pressFunc: () {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotiFastPhoto(),
              ));
        },
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      String? title = event.notification!.title;
      String? body = event.notification!.body;
      MyDialog(context: context).normalActionDilalog(
        title: title!,
        message: body!,
        label: 'ถ่ายรูป ร่วมสนุกกับ เพื่อนๆของคุณ',
        pressFunc: () {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotiFastPhoto(),
              ));
        },
      );
    });
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
