// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/show_elevate_icon_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:admanyout/widgets/widget_listtile.dart';

class SendOption extends StatefulWidget {
  final List<File?> files;
  const SendOption({
    Key? key,
    required this.files,
  }) : super(key: key);

  @override
  State<SendOption> createState() => _SendOptionState();
}

class _SendOptionState extends State<SendOption> {
  var options = <bool>[];
  var files = <File?>[];

  @override
  void initState() {
    super.initState();

    files = widget.files;

    for (var i = 0; i < 4; i++) {
      options.add(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyStyle.dark,
      appBar: newAppBar(),
      body: LayoutBuilder(
        builder: (p0, p1) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            newHeader(header: 'Send to...'),
            WidgetListtile(
              contentColor: MyStyle.bgColor,
              leadIcon: Icons.group,
              title: 'Friend Only',
              pressFunc: () {
                if (options[1]) {
                  options[0] = !options[0];
                  setState(() {});
                }
              },
              telingIcon: options[0] ? Icons.check : Icons.clear,
            ),
            const SizedBox(
              height: 16,
            ),
            WidgetListtile(
              contentColor: MyStyle.bgColor,
              leadIcon: Icons.language,
              title: 'Discovery',
              pressFunc: () {
                if (options[0]) {
                  options[1] = !options[1];
                  setState(() {});
                }
              },
              telingIcon: options[1] ? Icons.check : Icons.clear,
            ),
            const SizedBox(
              height: 16,
            ),
            WidgetListtile(
              contentColor: MyStyle.bgColor,
              leadIcon: Icons.location_on,
              title: 'Share My Location',
              pressFunc: () {
                options[2] = !options[2];
                setState(() {});
              },
              telingIcon: options[2] ? Icons.check : Icons.clear,
            ),
            const SizedBox(
              height: 16,
            ),
            WidgetListtile(
              contentColor: MyStyle.bgColor,
              leadIcon: Icons.save,
              title: 'Save on Device',
              pressFunc: () {
                options[3] = !options[3];
                setState(() {});
              },
              telingIcon: options[3] ? Icons.check : Icons.clear,
            ),
            const SizedBox(
              height: 16,
            ),
            ShowElevateButton(
              pressFunc: () {
                processUploadInsertData();
              },
              iconData: Icons.send,
              label: 'Send',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> processUploadInsertData() async {
    var user = FirebaseAuth.instance.currentUser;
    String uidLogin = user!.uid;
    int i = Random().nextInt(100000);
    int j = i + 1;
    String nameFile = '$uidLogin$i.jpg';
    String nameFile2 = '$uidLogin$j.jpg';

    var nameFiles = <String>[];
    nameFiles.add(nameFile);
    nameFiles.add(nameFile2);

    var urlImages = <String>[];

    DateTime dateTime = DateTime.now();

    for (var i = 0; i < 2; i++) {
      FirebaseStorage firebaseStorage = FirebaseStorage.instance;
      Reference reference =
          firebaseStorage.ref().child('photonoti/${nameFiles[i]}');
      UploadTask uploadTask = reference.putFile(files[i]!);
      await uploadTask.whenComplete(() async {
        await reference.getDownloadURL().then((value) async {
          urlImages.add(value);
          if (i == 1) {
            print('##5oct urlImages ==>> $urlImages');
          }
        });
      });
    }
  }

  Widget newHeader({required String header}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ShowText(
        label: header,
        textStyle: MyStyle().h2Style(
          color: MyStyle.bgColor,
          fontSize: 20,
        ),
      ),
    );
  }

  AppBar newAppBar() {
    return AppBar(
      centerTitle: true,
      title: ShowText(
        label: 'Send options',
        textStyle: MyStyle().h1Style(color: MyStyle.bgColor),
      ),
      foregroundColor: MyStyle.bgColor,
      backgroundColor: MyStyle.dark,
    );
  }
}
