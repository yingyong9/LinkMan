// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
import 'dart:io';
import 'dart:math';

import 'package:admanyout/models/messaging_model.dart';
import 'package:admanyout/models/sos_post_model.dart';
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/utility/my_process.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_button.dart';
import 'package:admanyout/widgets/show_form_long.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_image_avatar.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatRoom extends StatefulWidget {
  final String docIdMessaging;
  const ChatRoom({
    Key? key,
    required this.docIdMessaging,
  }) : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  String? docIdMessaging;
  MessageingModel? messageingModel;
  var user = FirebaseAuth.instance.currentUser;
  UserModel? userModelPartner;
  String? message;
  bool load = true;
  bool? haveDetail;
  var sosPostModels = <SosPostModel>[];
  File? file;

  TextEditingController formController = TextEditingController();

  @override
  void initState() {
    super.initState();
    docIdMessaging = widget.docIdMessaging;
    print('##13nov docIdMessaging = $docIdMessaging');
    findUserModelPartner();
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
          child: SizedBox(
            width: boxConstraints.maxWidth,
            height: boxConstraints.maxHeight,
            child: Stack(
              children: [
                load
                    ? const ShowProgress()
                    : haveDetail!
                        ? SizedBox(
                            height: boxConstraints.maxHeight - 75,
                            child: ListView.builder(
                              reverse: true,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: sosPostModels.length,
                              itemBuilder: (context, index) => Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    user!.uid == sosPostModels[index].uidPost
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  user!.uid == sosPostModels[index].uidPost
                                      ? const SizedBox()
                                      : ShowImageAvatar(
                                          urlImage: userModelPartner!.avatar!),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Column(
                                    children: [
                                      Container(padding: const EdgeInsets.all(16),
                                        decoration: MyStyle().bgCircleGrey(),
                                        child: ShowText(
                                          label: sosPostModels[index].post,
                                          textStyle: MyStyle().h3Style(),
                                        ),
                                      ),
                                      sosPostModels[index].urlImagePost!.isEmpty
                                          ? const SizedBox()
                                          : SizedBox(
                                              width: 200,
                                              child: Image.network(
                                                  sosPostModels[index]
                                                      .urlImagePost!)),
                                      ShowText(
                                        label: MyProcess().timeStampToString(
                                            timestamp:
                                                sosPostModels[index].timePost),
                                        textStyle: MyStyle().h3GreyStyle(
                                            color: Colors.grey.shade500),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),
                bottonContent(boxConstraints),
              ],
            ),
          ),
        );
      }),
    );
  }

  Column bottonContent(BoxConstraints boxConstraints) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ShowIconButton(
              iconData: Icons.camera,
              pressFunc: () async {
                var result = await MyProcess()
                    .processTakePhoto(source: ImageSource.camera);
                if (result != null) {
                  file = File(result.path);
                  processUpload();
                }
              },
              color: MyStyle.red,
            ),
            ShowIconButton(
              iconData: Icons.image,
              pressFunc: () async {
                var result = await MyProcess()
                    .processTakePhoto(source: ImageSource.gallery);
                if (result != null) {
                  file = File(result.path);
                  processUpload();
                }
              },
              color: MyStyle.red,
            ),
            SizedBox(
              width: boxConstraints.maxWidth * 0.5,
              child: ShowFormLong(
                textEditingController: formController,
                label: 'Message',
                changeFunc: (p0) {
                  message = p0.trim();
                },
              ),
            ),
            ShowButton(
              label: 'ส่ง',
              pressFunc: () async {
                if (message?.isNotEmpty ?? false) {
                  MyDialog(context: context).processDialog();

                  SosPostModel sosPostModel = SosPostModel(
                      post: message!,
                      uidPost: user!.uid,
                      timePost: Timestamp.fromDate(DateTime.now()));
                  await FirebaseFirestore.instance
                      .collection('messaging')
                      .doc(docIdMessaging)
                      .collection('detail')
                      .doc()
                      .set(sosPostModel.toMap())
                      .then((value) async {
                    Navigator.pop(context);
                    formController.text = '';
                    message = null;

                    // MyFirebase()
                    //     .sendNotiChat(
                    //         tokenSend: userModelPartner!.token!, body: '$message %23$docIdMessaging', title: 'มีข้อความเข้า %234')
                    //     .then((value) {
                    //   Navigator.pop(context);
                    //   formController.text = '';
                    //   message = null;
                    // });
                  });
                }
              },
            )
          ],
        ),
      ],
    );
  }

  AppBar newAppBar() {
    return AppBar(
      title: ShowText(
        label: userModelPartner?.name ?? '',
        textStyle: MyStyle().h2Style(),
      ),
    );
  }

  Future<void> findUserModelPartner() async {
    await FirebaseFirestore.instance
        .collection('messaging')
        .doc(docIdMessaging)
        .get()
        .then((value) async {
      messageingModel = MessageingModel.fromMap(value.data()!);
      var strings = messageingModel!.doubleMessages;
      strings.remove(user!.uid);
      print('##28oct strings ===> $strings');

      userModelPartner = await MyFirebase().findUserModel(uid: strings[0]);
      readAllDetail();
      setState(() {});
    });
  }

  Future<void> readAllDetail() async {
    FirebaseFirestore.instance
        .collection('messaging')
        .doc(docIdMessaging)
        .collection('detail')
        .orderBy('timePost', descending: true)
        .snapshots()
        .listen((event) {
      if (event.docs.isEmpty) {
        haveDetail = false;
      } else {
        haveDetail = true;
        if (sosPostModels.isNotEmpty) {
          sosPostModels.clear();
        }

        for (var element in event.docs) {
          SosPostModel model = SosPostModel.fromMap(element.data());
          sosPostModels.add(model);
        }
      }

      load = false;
      setState(() {});
    });
  }

  Future<void> processUpload() async {
    MyDialog(context: context).processDialog();

    String nameFile = '${user!.uid}${Random().nextInt(1000000)}.jpg';
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    Reference reference = firebaseStorage.ref().child('message/$nameFile');
    UploadTask task = reference.putFile(file!);
    await task.whenComplete(() async {
      await reference.getDownloadURL().then((value) async {
        String urlImage = value;
        print('urlImage => $urlImage');

        SosPostModel model = SosPostModel(
          post: '',
          uidPost: user!.uid,
          timePost: Timestamp.fromDate(
            DateTime.now(),
          ),
          urlImagePost: urlImage,
        );

        await FirebaseFirestore.instance
            .collection('messaging')
            .doc(docIdMessaging)
            .collection('detail')
            .doc()
            .set(model.toMap())
            .then((value) {
          Navigator.pop(context);
        });
      });
    });
  }
}
