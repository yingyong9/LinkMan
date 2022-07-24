// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_button.dart';
import 'package:admanyout/widgets/show_form.dart';
import 'package:admanyout/widgets/show_image.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File? file;
  TextEditingController textEditingController = TextEditingController();
  var user = FirebaseAuth.instance.currentUser;
  bool load = true, active = false;
  UserModel? userModel;
  String? newName;
  Map<String, dynamic> map = {};
  bool? shopBool;

  @override
  void initState() {
    super.initState();
    findCurrentUser();
    findShopUser();
  }

  Future<void> findShopUser() async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .collection('shop')
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        shopBool = false;
      } else {
        shopBool = true;
      }
      setState(() {});
    });
  }

  Future<void> findCurrentUser() async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .get()
        .then((value) {
      userModel = UserModel.fromMap(value.data()!);
      textEditingController.text = userModel!.name;
      load = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: newAppBar(),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).requestFocus(FocusScopeNode()),
        child: Center(
          child: LayoutBuilder(builder: (context, constraints) {
            return load
                ? const ShowProgress()
                : newContent(constraints, context);
          }),
        ),
      ),
    );
  }

  AppBar newAppBar() {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      title: ShowText(
        label: 'แก้ไขโปรไฟร์',
        textStyle: MyConstant().h2BlackBBBStyle(),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );
  }

  Column newContent(BoxConstraints constraints, BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 24),
          width: constraints.maxWidth * 0.6,
          height: constraints.maxWidth * 0.6,
          child: InkWell(
            onTap: () {
              MyDialog(context: context).twoActionDilalog(
                title: 'กรุณาเลือกรูป',
                message: 'คุณสามารถเลือกรูป จาก การถ่ายภาพ หรือ คลังภาพ',
                label1: 'Camera',
                label2: 'Gallery',
                pressFunc1: () {
                  Navigator.pop(context);
                  processTakePhoto(source: ImageSource.camera);
                },
                pressFunc2: () {
                  Navigator.pop(context);
                  processTakePhoto(source: ImageSource.gallery);
                },
              );
            },
            child: file == null
                ? userModel!.avatar!.isEmpty
                    ? const ShowImage(
                        path: 'images/avatar2.png',
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(userModel!.avatar!),
                      )
                : CircleAvatar(
                    backgroundImage: FileImage(file!),
                  ),
          ),
        ),
        ShowText(
          label: 'แตะที่รูป เพื่อเปลี่ยนรูป',
          textStyle: MyConstant().h3RedStyle(),
        ),
        ShowForm(
            colorTheme: Colors.black,
            controller: textEditingController,
            label: 'ชื่อ :',
            iconData: Icons.fingerprint,
            changeFunc: (String string) {
              active = true;
              newName = string.trim();
            }),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border.all(),
              borderRadius: BorderRadius.circular(10)),
          width: constraints.maxWidth * 0.6,
          child: CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: ShowText(
              label: 'เปิดใช้งาน Link Shop',
              textStyle: MyConstant().h3BlackStyle(),
            ),
            value: shopBool ?? false,
            onChanged: (value) {
              if (!shopBool!) {
                shopBool = value;
                setState(() {});
              }
            },
          ),
        ),
        shopBool == null
            ? const SizedBox()
            : shopBool!
                ? const SizedBox()
                : ShowText(
                    label: 'ถ้าเปิดใช้งาน Link Shop จะแก้ไขไม่ได้',
                    textStyle: MyConstant().h3RedStyle(),
                  ),
        SizedBox(
          width: constraints.maxWidth * 0.6,
          child: ShowButton(
              label: 'EditProfile',
              pressFunc: () {
                if (active) {
                  if (file != null) {
                    //upload image
                    processUploadImage();
                  } else {
                    // edit name
                    processEditName();
                  }
                }
              }),
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
    active = true;
    file = File(result!.path);
    setState(() {});
  }

  Future<void> processUploadImage() async {
    String nameImage = '${user!.uid}${Random().nextInt(100000)}.jpg';
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    Reference reference = firebaseStorage.ref().child('avatar/$nameImage');
    UploadTask uploadTask = reference.putFile(file!);
    await uploadTask.whenComplete(() async {
      await reference.getDownloadURL().then((value) {
        String urlAvatar = value;
        print('urlAvatar ==>> $urlAvatar');
        map['avatar'] = urlAvatar;
        processEditName();
      });
    });
  }

  Future<void> processEditName() async {
    if (newName?.isEmpty ?? true) {
      processUpdateProfile();
    } else {
      map['name'] = newName;
      processUpdateProfile();
    }
  }

  Future<void> processUpdateProfile() async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .update(map)
        .then((value) => Navigator.pop(context));
  }
}
