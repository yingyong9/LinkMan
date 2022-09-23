import 'dart:io';
import 'dart:math';

import 'package:admanyout/models/linkman_noti_model.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NotiFastPhoto extends StatefulWidget {
  const NotiFastPhoto({Key? key}) : super(key: key);

  @override
  State<NotiFastPhoto> createState() => _NotiFastPhotoState();
}

class _NotiFastPhotoState extends State<NotiFastPhoto> {
  File? file;

  @override
  void initState() {
    super.initState();
    processTakePhoto();
  }

  Future<void> processTakePhoto() async {
    var result = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxWidth: 800, maxHeight: 800);
    if (result != null) {
      file = File(result.path);

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyStyle.dark,
      // appBar: AppBar(),
      body: SafeArea(
          child: file == null
              ? const SizedBox()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ShowIconButton(
                            iconData: Icons.cancel,
                            pressFunc: () {
                              processTakePhoto();
                            },
                          ),
                        ],
                      ),
                      Image.file(file!),
                      ShowIconButton(
                        iconData: Icons.send,
                        pressFunc: () {
                          processUploadInsertData();
                        },
                      ),
                    ],
                  ),
                )),
    );
  }

  Future<void> processUploadInsertData() async {
    var user = FirebaseAuth.instance.currentUser;
    String uidLogin = user!.uid;
    String nameFile = '$uidLogin${Random().nextInt(100000)}.jpg';
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    Reference reference = firebaseStorage.ref().child('photonoti/$nameFile');
    UploadTask uploadTask = reference.putFile(file!);
    await uploadTask.whenComplete(() async {
      await reference.getDownloadURL().then((value) async {
        String urlImage = value;
        DateTime dateTime = DateTime.now();

        LinkManNotiModel linkManNotiModel = LinkManNotiModel(
            timePost: Timestamp.fromDate(dateTime),
            uidPost: uidLogin,
            urlImage: urlImage);

        await FirebaseFirestore.instance
            .collection('linkManNoti')
            .doc()
            .set(linkManNotiModel.toMap())
            .then((value) => Navigator.pop(context));
      });
    });
  }
}
