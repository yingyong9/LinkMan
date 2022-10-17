// ignore_for_file: avoid_print

import 'dart:math';

import 'package:admanyout/models/link_model.dart';
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/states2/grand_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyFirebase {
  Future<bool> checkLogin() async {
    bool result = true; // true SignIn Status
    var user = FirebaseAuth.instance.currentUser;
    print('##22sep user ==> $user');
    if (user == null) {
      result = false;
    }
    return result;
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
          token =
              'fd6N0wxzRQuyS5qKVplNuu:APA91bHl87iNOgFMdhqZHB_VWU5wFSwN5OTXNsc56Hc4qjBpoQkFqqiRWE5o7ruB7dGSmQvnAfr7ZrLnW_Gv7X7pMT1yXOVJeMcxXrV5TFhEhaGil5Xk8oRjiGnAYfaIDRanxny3LCTI';

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
