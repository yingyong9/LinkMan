import 'dart:math';

import 'package:admanyout/models/link_model.dart';
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/states/search_shortcode.dart';
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

  Future<void> sentNoti() async {
    String title = 'ถ่ายรูป บอกให้โลกรู้';
    String body = 'คุณมีเวลา 2 นาที';

    var docIdUsers = <String>[];

    await FirebaseFirestore.instance
        .collection('user')
        .get()
        .then((value) async {
      for (var element in value.docs) {
        docIdUsers.add(element.id);
      }

      int index = Random().nextInt(docIdUsers.length);
      print('## index ==> $index ==> uid = ${docIdUsers[index]}');

      await FirebaseFirestore.instance
          .collection('user')
          .doc(docIdUsers[index])
          .get()
          .then((value) async {
        UserModel userModel = UserModel.fromMap(value.data()!);

        if (userModel.token!.isNotEmpty) {
          String? token = userModel.token;
          print('token ==> $token');

          String path =
              'https://www.androidthai.in.th/flutter/linkman/linkManNoti.php?isAdd=true&token=$token&title=$title&body=$body';
          await Dio().get(path).then((value) {
            print('##19sep SentNoti Success');
          });
        }
      });
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
