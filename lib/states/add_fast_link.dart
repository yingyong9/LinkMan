// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:math';

import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_button.dart';
import 'package:admanyout/widgets/show_form.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddFastLink extends StatefulWidget {
  final String sixCode;
  final String addLink;

  const AddFastLink({
    Key? key,
    required this.sixCode,
    required this.addLink,
  }) : super(key: key);

  @override
  State<AddFastLink> createState() => _AddFastLinkState();
}

class _AddFastLinkState extends State<AddFastLink> {
  File? file;
  String? sixCode, addLink, detail;
  var user = FirebaseAuth.instance.currentUser;
  UserModel? userModelLogined;

  @override
  void initState() {
    super.initState();
    sixCode = widget.sixCode;
    addLink = widget.addLink;
    processGetImage();
    processFindUserLogined();
  }

  Future<void> processFindUserLogined() async {
    userModelLogined = await MyFirebase().findUserModel(uid: user!.uid);
    setState(() {});
  }

  Future<void> processGetImage() async {
    var result = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (result != null) {
      setState(() {
        file = File(result.path);
      });
    } else {
      processGetImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: newAppBar(),
      body: file == null
          ? const ShowProgress()
          : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints boxConstraints) {
              return ListView(
                children: [
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                            userModelLogined!.avatar ?? MyConstant.urlLogo),
                      ),
                      newTitle(
                          boxConstraints: boxConstraints, string: addLink!),
                    ],
                  ),
                  newImage(boxConstraints),
                  formDetail(boxConstraints),
                  // newTitle(
                  //     boxConstraints: boxConstraints,
                  //     string: 'This is groupFastPost'),
                  // formAddNewGroupFastPost(boxConstraints),
                  buttonPost(),
                ],
              );
            }),
    );
  }

  SizedBox buttonPost() {
    return SizedBox(
      child: ShowButton(
        label: 'Post >',
        pressFunc: () {
          if (detail?.isEmpty ?? true) {
            detail = '';
          }
          processUploadAndInsertFastLink();
        },
      ),
    );
  }

  Future<void> processUploadAndInsertFastLink() async {
    String nameImage = '${user!.uid}${Random().nextInt(1000000)}.jpg';
    print( 'nameImage => $nameImage ==== pathImage ?');
  }

  Row formDetail(BoxConstraints boxConstraints) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          width: boxConstraints.maxWidth * 0.65,
          child: ShowForm(
            colorTheme: Colors.black,
            label: 'อยากบอกอะไร :',
            iconData: Icons.details_outlined,
            changeFunc: (String string) {
              detail = string.trim();
            },
          ),
        ),
      ],
    );
  }

  Row formAddNewGroupFastPost(BoxConstraints boxConstraints) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          width: boxConstraints.maxWidth * 0.65,
          child: ShowForm(
            colorTheme: Colors.black,
            label: 'groupFastPost :',
            iconData: Icons.details_outlined,
            changeFunc: (String string) {},
          ),
        ),
      ],
    );
  }

  Row newTitle(
      {required BoxConstraints boxConstraints, required String string}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          width: boxConstraints.maxWidth * 0.65,
          decoration: MyConstant().curveBorderBox(),
          child: ShowText(
            label: string,
            textStyle: MyConstant().h3BlackStyle(),
          ),
        ),
      ],
    );
  }

  Row newImage(BoxConstraints boxConstraints) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              width: boxConstraints.maxWidth * 0.65,
              height: boxConstraints.maxWidth * 0.65,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: FileImage(file!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ShowIconButton(
              iconData: Icons.add_photo_alternate,
              pressFunc: () {
                processGetImage();
              },
            ),
          ],
        ),
      ],
    );
  }

  AppBar newAppBar() {
    return AppBar(
      title: Text(widget.sixCode),
      foregroundColor: Colors.black,
      elevation: 0,
      backgroundColor: Colors.white,
    );
  }
}