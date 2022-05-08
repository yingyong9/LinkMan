import 'package:admanyout/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyFirebase {
  Future<UserModel> findUserModel({required String uid}) async {
    var object =
        await FirebaseFirestore.instance.collection('user').doc(uid).get();
    UserModel userModel = UserModel.fromMap(object.data()!);
    return userModel;
  }
}
