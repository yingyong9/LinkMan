// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:admanyout/models/sos_model.dart';
import 'package:admanyout/states2/send_option.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/utility/my_process.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_button.dart';
import 'package:admanyout/widgets/show_form_long.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_image_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class NotiFastPhoto extends StatefulWidget {
  const NotiFastPhoto({Key? key}) : super(key: key);

  @override
  State<NotiFastPhoto> createState() => _NotiFastPhotoState();
}

class _NotiFastPhotoState extends State<NotiFastPhoto> {
  var files = <File?>[];
  bool discovery = false, friend = false;

  String? textHelp;

  @override
  void initState() {
    super.initState();
    files.add(null);
    files.add(null);
    processTakePhoto(index: 0);
  }

  Future<void> processTakePhoto({required int index}) async {
    await ImagePicker()
        .pickImage(source: ImageSource.camera, maxWidth: 800, maxHeight: 800)
        .then((value) async {
      var result = value;
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
    }).catchError((onError) {
      print('onError Take Photo ==> $onError');
    });
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
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        FocusScope.of(context).requestFocus(FocusScopeNode()),
                    child: SingleChildScrollView(
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
                          SizedBox(
                            width: boxConstraints.maxWidth,
                            height: boxConstraints.maxHeight - 180,
                            child: Stack(
                              children: [
                                Image.file(
                                  files[0]!,
                                  fit: BoxFit.cover,
                                ),
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
                          SizedBox(
                            width: boxConstraints.maxWidth * 0.75,
                            child: ShowFormLong(
                              label: 'ขอความช่วยเหลือ',
                              changeFunc: (p0) {
                                textHelp = p0.trim();
                              },
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ShowButton(
                                label: 'ยกเลิกความช่วยเหลือ',
                                pressFunc: () {
                                  Navigator.pop(context);
                                },
                              ),
                              ShowButton(
                                label: 'ขอความช่วยเหลือ',
                                pressFunc: () async {
                                  if (textHelp == null) {
                                    Fluttertoast.showToast(
                                        msg: 'กรุณากรอกข้อความ');
                                  } else {
                                    var urlImages = <String>[];

                                    for (var element in files) {
                                      String nameFile =
                                          'sos${Random().nextInt(1000000)}.jpg';
                                      FirebaseStorage storage =
                                          FirebaseStorage.instance;
                                      Reference reference =
                                          storage.ref().child('sos/$nameFile');
                                      UploadTask uploadTask =
                                          reference.putFile(element!);
                                      await uploadTask.whenComplete(() async {
                                        await reference
                                            .getDownloadURL()
                                            .then((value) {
                                          urlImages.add(value.toString());
                                        });
                                      });
                                    }
                                    // print('##13oct urlImags ==> $urlImages');

                                    if (urlImages.isNotEmpty) {
                                      DateTime dateTime = DateTime.now();
                                      var user =
                                          FirebaseAuth.instance.currentUser;

                                      Position? position = await MyProcess()
                                          .processFindPosition(
                                              context: context);

                                      SosModel sosModel = SosModel(
                                          sosGeopoint: GeoPoint(
                                              position!.latitude,
                                              position.longitude),
                                          timeSos: Timestamp.fromDate(dateTime),
                                          uidSos: user!.uid,
                                          urlBig: urlImages[0],
                                          urlSmall: urlImages[1],
                                          textHelp: textHelp!);

                                      await FirebaseFirestore.instance
                                          .collection('sos')
                                          .doc()
                                          .set(sosModel.toMap())
                                          .then((value) async {
                                        print('##14oct insert sos success');



                                        await MyFirebase()
                                            .sentNoti(
                                              titleNoti: 'ขอความช่วยเหลือ %232',
                                              bodyNoti: textHelp,
                                            )
                                            .then((value) =>
                                                Navigator.pop(context));
                                      });
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                          // ShowImageIconButton(
                          //   path: 'images/sendblue.png',
                          //   size: 72,
                          //   pressFunc: () {
                          //     Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) => SendOption(
                          //             files: files,
                          //           ),
                          //         ));
                          //   },
                          // ),
                        ],
                      ),
                    ),
                  );
                })),
    );
  }
}
