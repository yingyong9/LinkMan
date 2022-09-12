import 'dart:math';

import 'package:admanyout/models/link_model.dart';
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/states/search_shortcode.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyFirebase {
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
            builder: (context) => const SearchShortCode(),
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
