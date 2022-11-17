import 'package:admanyout/states/create_new_account.dart';
import 'package:admanyout/states/search_shortcode.dart';
import 'package:admanyout/states2/grand_home.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/widgets/show_button.dart';
import 'package:admanyout/widgets/show_form.dart';
import 'package:admanyout/widgets/show_image.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:admanyout/widgets/show_text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Authen extends StatefulWidget {
  const Authen({Key? key}) : super(key: key);

  @override
  State<Authen> createState() => _AuthenState();
}

class _AuthenState extends State<Authen> {
  String? email, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusScopeNode()),
        behavior: HitTestBehavior.opaque,
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16, top: 80),
                  width: 250,
                  child: Row(
                    children: [
                      ShowImage(
                        path: 'images/logo.png',
                        width: 80,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: ShowText(
                    label: 'Login :',
                    textStyle: MyConstant().h1Style(),
                  ),
                ),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShowForm(
                  textInputType: TextInputType.emailAddress,
                  label: 'Email :',
                  iconData: Icons.email_outlined,
                  changeFunc: (String string) => email = string.trim(),
                ),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShowForm(
                  obscub: true,
                  label: 'Password :',
                  iconData: Icons.lock_outline,
                  changeFunc: (String string) => password = string.trim(),
                ),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // ShowTextButton(label: 'Forgot Password', pressFunc: () {}),
                      ShowButton(
                        label: 'Login',
                        pressFunc: () {
                          if ((email?.isEmpty ?? true) ||
                              (password?.isEmpty ?? true)) {
                            MyDialog(context: context).normalActionDilalog(
                                title: 'Have Space ?',
                                message: 'Please Fill Every Blank',
                                label: 'OK',
                                pressFunc: () => Navigator.pop(context));
                          } else {
                            processChcekAuthen();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ShowText(label: 'Non Account ? '),
                ShowTextButton(
                  label: 'Create New Account',
                  pressFunc: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateNewAccount(),
                        ));
                  },
                )
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 250,
                  child: Row(mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShowTextButton(label: '(สมัครสมาชิกใหม่)', pressFunc: (){ Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CreateNewAccount(),
                                  ));}),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> processChcekAuthen() async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email!, password: password!)
        .then((value) => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const GrandHome(),
            ),
            (route) => false))
        .catchError((onError) => MyDialog(context: context).normalActionDilalog(
            title: onError.code,
            message: onError.message,
            label: 'OK',
            pressFunc: () => Navigator.pop(context)));
  }
}
