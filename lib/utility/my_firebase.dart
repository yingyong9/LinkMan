import 'dart:math';

import 'package:admanyout/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyFirebase {
  Future<UserModel> findUserModel({required String uid}) async {
    var object =
        await FirebaseFirestore.instance.collection('user').doc(uid).get();
    UserModel userModel = UserModel.fromMap(object.data()!);
    return userModel;
  }

  String getRandom(int length){
    const ch = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random r = Random();
    return String.fromCharCodes(Iterable.generate(
    length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
}
} // Class
