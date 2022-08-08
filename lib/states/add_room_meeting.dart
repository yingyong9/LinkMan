import 'dart:io';

import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/show_button.dart';
import 'package:admanyout/widgets/show_circle_image.dart';
import 'package:admanyout/widgets/show_form.dart';
import 'package:admanyout/widgets/show_form_long.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_image.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class AddRoomMeeting extends StatefulWidget {
  const AddRoomMeeting({Key? key}) : super(key: key);

  @override
  State<AddRoomMeeting> createState() => _AddRoomMeetingState();
}

class _AddRoomMeetingState extends State<AddRoomMeeting> {
  var user = FirebaseAuth.instance.currentUser;
  UserModel? userModel;
  File? file;
  String? linkMeeting, urlImageRoom, nameRoom, nameOwner, tokenOwner;
  Timestamp? addTimeStamp;

  @override
  void initState() {
    super.initState();
    processFindUserModel();
  }

  Future<void> processFindUserModel() async {
    await MyFirebase().findUserModel(uid: user!.uid).then((value) {
      userModel = value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyStyle.bgColor,
      appBar: newAppBar(),
      body: LayoutBuilder(builder: (context, BoxConstraints boxConstraints) {
        return ListView(
          children: [
            createCenter(
              boxConstraints: boxConstraints,
              widget: ShowForm(
                colorTheme: MyStyle.dark,
                label: 'อยากบอกอะไร',
                iconData: Icons.room,
                changeFunc: (p0) {
                  nameRoom = p0.trim();
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: boxConstraints.maxWidth * 0.6,
                      height: boxConstraints.maxWidth * 0.6,
                      child: InkWell(
                        onTap: () {
                          processTakePhoto(source: ImageSource.gallery);
                        },
                        child: file == null
                            ? const ShowImage(
                                path: 'images/logo.png',
                              )
                            : Image.file(file!),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: ShowIconButton(
                        color: Colors.red,
                        size: 36,
                        iconData: Icons.camera,
                        pressFunc: () {
                          processTakePhoto(source: ImageSource.camera);
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
            createCenter(
              boxConstraints: boxConstraints,
              widget: ShowFormLong(
                label: 'กรุณาใส่ Link Meeting',
                changeFunc: (p0) {
                  linkMeeting = p0.trim();
                },
              ),
            ),
            createCenter(
                boxConstraints: boxConstraints,
                widget: ShowButton(
                  label: 'OK',
                  pressFunc: () {
                    if (nameRoom?.isEmpty ?? true) {
                      Fluttertoast.showToast(msg: 'กรุณากรอก อยากบอกอะไร');
                    } else if (linkMeeting?.isEmpty ?? true) {
                      Fluttertoast.showToast(msg: 'กรุณากรอก Link Meeting');
                    }
                  },
                ))
          ],
        );
      }),
    );
  }

  AppBar newAppBar() {
    return AppBar(
      title: userModel == null
          ? const SizedBox()
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShowCircleImage(path: userModel!.avatar!),
                const SizedBox(
                  width: 8,
                ),
                ShowText(
                  label: userModel!.name,
                  textStyle: MyConstant().h2BlackBBBStyle(),
                ),
              ],
            ),
      elevation: 0,
      backgroundColor: MyStyle.bgColor,
      foregroundColor: MyStyle.dark,
    );
  }

  Row createCenter(
      {required BoxConstraints boxConstraints, required Widget widget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: boxConstraints.maxWidth * 0.6,
          child: widget,
        ),
      ],
    );
  }

  Future<void> processTakePhoto({required ImageSource source}) async {
    var result = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (result != null) {
      file = File(result.path);
      setState(() {});
    }
  }
}
