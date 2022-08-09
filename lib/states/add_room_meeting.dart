import 'dart:io';
import 'dart:math';

import 'package:admanyout/models/room_model.dart';
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
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_password_generator/random_password_generator.dart';

class AddRoomMeeting extends StatefulWidget {
  const AddRoomMeeting({Key? key}) : super(key: key);

  @override
  State<AddRoomMeeting> createState() => _AddRoomMeetingState();
}

class _AddRoomMeetingState extends State<AddRoomMeeting> {
  var user = FirebaseAuth.instance.currentUser;
  UserModel? userModel;
  File? file;
  String? linkMeeting, urlImageRoom, nameRoom, nameOwner, tokenOwner, idRoom;
  String linkContact = '', password = '';
  bool usePassword = false;

  GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    processFindUserModel();
    readAllRoom();
  }

  void createPassword() {
    final genPassword = RandomPasswordGenerator();
    password = genPassword.randomPassword(
        letters: true,
        uppercase: true,
        numbers: true,
        specialChar: false,
        passwordLength: 6);
    setState(() {});
    print('password ====> $password');
  }

  Future<void> readAllRoom() async {
    await FirebaseFirestore.instance.collection('room').get().then((value) {
      int amountRoom = value.docs.length;
      amountRoom = amountRoom + 100 + 1;
      idRoom = '#L$amountRoom';
      print('idRoom ===> $idRoom');
    });
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
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).requestFocus(FocusScopeNode()),
          child: ListView(
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
                  widget: ShowFormLong(
                    label: 'Link ที่ใช้ติดต่อ',
                    changeFunc: (p0) {
                      linkContact = p0.trim();
                    },
                  )),
              createCenter(
                boxConstraints: boxConstraints,
                widget: ShowButton(
                  label: 'OK',
                  pressFunc: () {
                    if (nameRoom?.isEmpty ?? true) {
                      Fluttertoast.showToast(msg: 'กรุณากรอก อยากบอกอะไร');
                    } else if (linkMeeting?.isEmpty ?? true) {
                      Fluttertoast.showToast(msg: 'กรุณากรอก Link Meeting');
                    } else {
                      if (file == null) {
                        urlImageRoom = MyConstant.urlLogo;
                        processInsertRoom();
                      } else {
                        processUploadImage();
                      }
                    }
                  },
                ),
              ),
              createCenter(
                boxConstraints: boxConstraints,
                widget: SwitchListTile(
                  title: ShowText(
                    label: 'เปิดเพื่อใช้ รหัสผ่าน',
                    textStyle: MyConstant().h3BlackStyle(),
                  ),
                  value: usePassword,
                  onChanged: (value) {
                    usePassword = value;
                    if (!usePassword) {
                      password = '';
                    }
                    setState(() {});
                  },
                ),
              ),
              usePassword
                  ? createCenter(
                      boxConstraints: boxConstraints,
                      widget: ShowButton(
                        label: 'กดเพื่อสร้างรหัสผ่าน',
                        pressFunc: () {
                          createPassword();
                        },
                      ),
                    )
                  : const SizedBox(),
              password.isNotEmpty
                  ? createCenter(
                      addWidth: 50,
                      boxConstraints: boxConstraints,
                      widget: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ShowText(
                            label: 'RoomPassword: ',
                            textStyle: MyConstant().h2BlackBBBStyle(),
                          ),
                          ShowText(
                            label: password,
                            textStyle: MyConstant().h2redStyle(),
                          ),
                        ],
                      ))
                  : const SizedBox(),
              password.isNotEmpty
                  ? RepaintBoundary(
                      key: globalKey,
                      child: createCenter(boxConstraints: boxConstraints, widget: QrImage(data: password)),
                    )
                  : const SizedBox(),
            ],
          ),
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
      {required BoxConstraints boxConstraints,
      required Widget widget,
      double? addWidth}) {
    double width = addWidth ?? 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: boxConstraints.maxWidth * 0.6 + width,
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

  Future<void> processInsertRoom() async {
    DateTime dateTime = DateTime.now();

    RoomModel roomModel = RoomModel(
        idRoom: idRoom!,
        linkContact: linkContact,
        linkRoom: linkMeeting!,
        nameRoom: nameRoom!,
        password: password,
        timeDateAdd: Timestamp.fromDate(dateTime),
        uidOwner: user!.uid,
        urlImage: urlImageRoom!,
        usePassword: false);
  }

  Future<void> processUploadImage() async {
    String nameImage = '${user!.uid}${Random().nextInt(10000)}.jpg';
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference reference = storage.ref().child('room/$nameImage');
    UploadTask task = reference.putFile(file!);
    await task.whenComplete(() async {
      await reference.getDownloadURL().then((value) {
        urlImageRoom = value;
        print('urlImageRoom ==> $urlImageRoom');
        processInsertRoom();
      });
    });
  }
}