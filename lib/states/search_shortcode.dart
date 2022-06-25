// ignore_for_file: avoid_print

import 'package:admanyout/models/post_model2.dart';
import 'package:admanyout/states/add_fast_link.dart';
import 'package:admanyout/states/add_photo_multi.dart';
import 'package:admanyout/states/authen.dart';
import 'package:admanyout/states/main_home.dart';
import 'package:admanyout/states/show_detail_post.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/widgets/show_form.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_outline_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SearchShortCode extends StatefulWidget {
  const SearchShortCode({Key? key}) : super(key: key);

  @override
  State<SearchShortCode> createState() => _SearchShortCodeState();
}

class _SearchShortCodeState extends State<SearchShortCode> {
  String? search;
  TextEditingController controller = TextEditingController();
  bool? statusLoginBool;

  String? addNewLink;

  @override
  void initState() {
    super.initState();
    checkStatusLogin();
  }

  Future<void> checkStatusLogin() async {
    FirebaseAuth.instance.authStateChanges().listen((event) {
      if (event == null) {
        statusLoginBool = false;
      } else {
        statusLoginBool = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: newAppBar(context),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).requestFocus(FocusScopeNode()),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints boxConstraints) {
          return SizedBox(
            width: boxConstraints.maxWidth,
            height: boxConstraints.maxHeight,
            child: Stack(
              children: [
                formSearchShortCode(),
                newAddLink(),
              ],
            ),
          );
        }),
      ),
    );
  }

  Positioned newAddLink() {
    return Positioned(
      bottom: 0,
      child: Container(
        margin: const EdgeInsets.only(left: 48),
        child: ShowForm(
          label: 'Add Link',
          iconData: Icons.arrow_forward_ios,
          changeFunc: (String string) {
            addNewLink = string.trim();
          },
          pressFunc: () {
            if (addNewLink?.isEmpty ?? true) {
              Fluttertoast.showToast(
                  msg: 'Please Fill Add Link', textColor: Colors.red);
            } else {
              String sixCode = MyFirebase().getRandom(6);
              sixCode = '#$sixCode';
              print('sixCode ===>> $sixCode');
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddFastLink(sixCode: sixCode, addLink: addNewLink!),
                  )).then((value) {});
            }
          },
        ),
      ),
    );
  }

  Row formSearchShortCode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShowForm(
            controller: controller,
            label: 'LinkMan #',
            iconData: Icons.qr_code,
            changeFunc: (String string) {
              search = string.trim();
            }),
        Container(
          margin: const EdgeInsets.only(top: 16, left: 4),
          child: ShowOutlineButton(
              label: 'OK',
              pressFunc: () {
                if (!(search?.isEmpty ?? true)) {
                  print('search ==> $search');
                  processFindShortCode();
                }
              }),
        ),
      ],
    );
  }

  Future<void> processFindShortCode() async {
    await FirebaseFirestore.instance
        .collection('post2')
        .where('shortcode', isEqualTo: search)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        for (var element in value.docs) {
          PostModel2 postModel2 = PostModel2.fromMap(element.data());
          // print('postModel2 ===> ${postModel2.toMap()}');
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShowDetailPost(postModel2: postModel2),
              ));
        }
        controller.text = '';
      } else {
        Fluttertoast.showToast(
            toastLength: Toast.LENGTH_LONG,
            msg: 'No $search in ShortCode',
            textColor: const Color.fromARGB(255, 236, 12, 12));
      }
    });
  }

  AppBar newAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: InkWell(
        onTap: () {
          if (statusLoginBool!) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainHome(),
                ));
          } else {
            alertLogin(context);
          }
        },
        child: ShowText(
          label: 'LINKMAN',
          textStyle: MyConstant().h1Style(),
        ),
      ),
      actions: [
        ShowIconButton(
          size: 36,
          color: const Color.fromARGB(255, 236, 12, 12),
          iconData: Icons.add_box_outlined,
          pressFunc: () {
            if (statusLoginBool!) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // builder: (context) => const AddPhoto(),
                  builder: (context) => const AddPhotoMulti(),
                ),
              );
            } else {
              alertLogin(context);
            }
          },
        ),
      ],
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    );
  }

  void alertLogin(BuildContext context) {
    MyDialog(context: context).normalActionDilalog(
        title: 'No Login ?',
        message: 'Please Login',
        label: 'Login',
        pressFunc: () {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Authen(),
              ));
        });
  }
}
