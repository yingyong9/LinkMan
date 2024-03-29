// ignore_for_file: avoid_print

import 'dart:math';

import 'package:admanyout/models/link_model.dart';
import 'package:admanyout/models/messaging_model.dart';
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/states2/grand_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyFirebase {
  Future<String?> findDocIdMessaging(
      {required String uidLogin, required String uidParter}) async {
    String? string;
    var result = await FirebaseFirestore.instance.collection('messaging').get();
    if (result.docs.isNotEmpty) {
      for (var element in result.docs) {
        MessageingModel messageingModel =
            MessageingModel.fromMap(element.data());
        var doubleMessages = messageingModel.doubleMessages;
        if ((doubleMessages.contains(uidLogin)) &&
            (doubleMessages.contains(uidParter))) {
          string = element.id;
        }
      }
    }
    return string;
  }

  Future<bool> checkLogin() async {
    bool result = true; // true SignIn Status
    var user = FirebaseAuth.instance.currentUser;
    print('##22sep user ==> $user');
    if (user == null) {
      result = false;
    }
    return result;
  }

  Future<void> sendNotiChat(
      {required String tokenSend, String? title, String? body}) async {
    String titleSend = title ?? 'มีข้อความเข้า';
    String bodySend = body ?? 'มีข่าวสาร';
    String url =
        'https://www.androidthai.in.th/flutter/linkman/linkManNoti.php?isAdd=true&token=$tokenSend&title=$titleSend&body=$bodySend';
    await Dio().get(url).then((value) {
      print('##13nov sendNotiChat Success');
    });
  }

  Future<void> sentNoti({String? titleNoti, String? bodyNoti}) async {
    String title = titleNoti ?? 'วันนี่ คุณอยากบอก อะไร เพื่อนคุณ %231';
    String body = bodyNoti ?? 'คลิกเพื่อ สร้าง Post';

    // print('##14oct title ==> $title, body ==> $body');

    var docIdUsers = <String>[];

    await FirebaseFirestore.instance
        .collection('user')
        .get()
        .then((value) async {
      for (var element in value.docs) {
        UserModel userModel = UserModel.fromMap(element.data());
        if (userModel.token!.isNotEmpty) {
          String? token = userModel.token;

          //สำหรับ การทดสอบ จะ fix token
          // token =
          //     'dHHflP_zTbqEJwElT1k0e8:APA91bG0FG0xRfNvvNEjQeJ6Bl499a-953KLvc1mlwBaEC68iKgMmzrBTUWMlq5jpscF2QHKi5m7laQ4A5CDSK5yKmA73MDVSUJDR8ruMNMOtxzHeWmoS51YP9IAXohhdhU9LdTlHg16';

          String path =
              'https://www.androidthai.in.th/flutter/linkman/linkManNoti.php?isAdd=true&token=$token&title=$title&body=$body';

          await Dio().get(path).then((value) {
            // print('##14oct SentNoti Success');
          });
        }
      }
    });
  }

  Future<void> updateToken({required String uid, required String token}) async {
    Map<String, dynamic> map = {};
    map['token'] = token;

    await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .update(map)
        .then((value) {
      print('##19sep update Token Success');
    });
  }

  Future<void> addNewLinkToUser(
      {required String uidUser, required LinkModel linkModel}) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(uidUser)
        .collection('link')
        .doc()
        .set(linkModel.toMap())
        .then((value) {
      print('### addNewLinkToUser Success');
    });
  }

  Future<List<String>> findDocIdRoomWhereKeyRoom(
      {required String keyRoom}) async {
    var docIdRooms = <String>[];
    var result = await FirebaseFirestore.instance
        .collection('room')
        .where('keyRoom', isEqualTo: keyRoom)
        .get();

    for (var element in result.docs) {
      docIdRooms.add(element.id);
    }
    return docIdRooms;
  }

  Future<void> processSignOut({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut().then((value) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const GrandHome(),
          ),
          (route) => false);
    });
  }

  Future<UserModel> findUserModel({required String uid}) async {
    var object =
        await FirebaseFirestore.instance.collection('user').doc(uid).get();
    UserModel userModel = UserModel.fromMap(object.data()!);
    return userModel;
  }

  String getRandom(int length) {
    const ch = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random r = Random();
    return String.fromCharCodes(
        Iterable.generate(length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
  }
} // Class
