import 'dart:io';
import 'dart:math';

import 'package:admanyout/models/linkman_noti_model.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/widget_check_box_list.dart';
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
  var files = <File?>[];
  bool discovery = false, friend = false;

  @override
  void initState() {
    super.initState();
    files.add(null);
    files.add(null);
    processTakePhoto(index: 0);
  }

  Future<void> processTakePhoto({required int index}) async {
    var result = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxWidth: 800, maxHeight: 800);
    if (result != null) {
      files[index] = File(result.path);
      setState(() {});

      if (files[1] == null) {
        await Future.delayed(
          const Duration(seconds: 3),
          () {
            processTakePhoto(index: 1);
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyStyle.dark,
      // appBar: AppBar(),
      body: SafeArea(
          child: files[0] == null
              ? const SizedBox()
              : LayoutBuilder(
                  builder: (context, BoxConstraints boxConstraints) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ShowIconButton(
                              iconData: Icons.cancel,
                              pressFunc: () {
                                processTakePhoto(index: 0);
                              },
                            ),
                          ],
                        ),
                        Container(
                          width: boxConstraints.maxWidth,
                          height: boxConstraints.maxHeight - 96,
                          child: Stack(
                            children: [
                              Image.file(files[0]!),
                              Container(
                                // decoration: MyStyle().curveBorderBox(curve: 30),
                                margin:
                                    const EdgeInsets.only(top: 16, left: 16),
                                width: boxConstraints.maxWidth * 0.25,
                                height: boxConstraints.maxWidth * 0.3,
                                child: files[1] == null
                                    ? const ShowProgress()
                                    : Image.file(
                                        files[1]!,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 140,
                              // height: 48,
                              child: WidgetCheckBoxLis(
                                status: friend,
                                title: 'Friend',
                                statusFunc: (p0) {
                                  friend = p0!;
                                  setState(() {});
                                },
                              ),
                            ),
                            SizedBox(
                              width: 150,
                              // height: 48,
                              child: WidgetCheckBoxLis(
                                status: discovery,
                                title: 'Discovery',
                                statusFunc: (p0) {
                                  discovery = p0!;
                                  setState(() {});
                                },
                              ),
                            ),
                            ShowIconButton(
                              iconData: Icons.send,
                              pressFunc: () {
                                processUploadInsertData();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                })),
    );
  }

  Future<void> processUploadInsertData() async {
    var user = FirebaseAuth.instance.currentUser;
    String uidLogin = user!.uid;
    int i = Random().nextInt(100000);
    int j = i+1;
    String nameFile = '$uidLogin$i.jpg';
    String nameFile2 = '$uidLogin$j.jpg';
    
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    Reference reference = firebaseStorage.ref().child('photonoti/$nameFile');
    UploadTask uploadTask = reference.putFile(files[0]!);
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
