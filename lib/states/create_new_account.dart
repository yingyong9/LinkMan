// ignore_for_file: invalid_return_type_for_catch_error

import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/widgets/show_button.dart';
import 'package:admanyout/widgets/show_form.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateNewAccount extends StatefulWidget {
  const CreateNewAccount({Key? key}) : super(key: key);

  @override
  State<CreateNewAccount> createState() => _CreateNewAccountState();
}

class _CreateNewAccountState extends State<CreateNewAccount> {
  String? name, email, password, rePassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).requestFocus(FocusScopeNode()),
        child: ListView(
          children: [
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShowText(
                  label: 'Create Account',
                  textStyle: MyConstant().h1Style(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShowForm(
                  label: 'Display Name :',
                  iconData: Icons.fingerprint,
                  changeFunc: (String string) => name = string.trim(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShowForm(
                    label: 'Email :',
                    iconData: Icons.email_outlined,
                    changeFunc: (String string) => email = string.trim()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShowForm(
                  obscub: true,
                  label: 'Password :',
                  iconData: Icons.lock_outline,
                  changeFunc: (String string) => password = string.trim(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShowForm(
                  obscub: true,
                  label: 'Re Password :',
                  iconData: Icons.lock_outline,
                  changeFunc: (String string) => rePassword = string.trim(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShowButton(
                  label: 'Create Account',
                  pressFunc: () {
                    if ((name?.isEmpty ?? true) ||
                        (email?.isEmpty ?? true) ||
                        (password?.isEmpty ?? true) ||
                        (rePassword?.isEmpty ?? true)) {
                      MyDialog(context: context).normalActionDilalog(
                          title: 'มีช่องว่าง',
                          message: 'กรุณากรอง ทุกช่อง คะ',
                          label: 'OK',
                          pressFunc: () => Navigator.pop(context));
                    } else if (password != rePassword) {
                      MyDialog(context: context).normalActionDilalog(
                          title: 'Password ไม่เหมือนกัน',
                          message:
                              'กรุณา กรอก Password และ Repassword ให้เหมือนกัน',
                          label: 'OK',
                          pressFunc: () => Navigator.pop(context));
                    } else {
                      processCreateNewAccount();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> processCreateNewAccount() async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email!, password: password!)
        .then((value) async {
      String uid = value.user!.uid;
      UserModel userModel =
          UserModel(email: email!, name: name!, password: password!);
      await FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .set(userModel.toMap())
          .then((value) {
        Navigator.pop(context);
      });
    }).catchError((onError) {
      return MyDialog(context: context).normalActionDilalog(
          title: onError.code,
          message: onError.message,
          label: 'OK',
          pressFunc: () => Navigator.pop(context));
    });
  }
}
