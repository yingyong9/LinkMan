// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
import 'dart:io';
import 'dart:math';

import 'package:admanyout/models/messaging_model.dart';
import 'package:admanyout/models/sos_post_model.dart';
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/states2/chat_room.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/utility/my_process.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_circle_image.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:admanyout/widgets/widget_image_internet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:admanyout/widgets/show_button.dart';
import 'package:admanyout/widgets/show_form_long.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ChatDiscovery extends StatefulWidget {
  final String docIdFastLink;
  const ChatDiscovery({
    Key? key,
    required this.docIdFastLink,
  }) : super(key: key);

  @override
  State<ChatDiscovery> createState() => _ChatDiscoveryState();
}

class _ChatDiscoveryState extends State<ChatDiscovery> {
  String? post, docIdFastLink;
  var user = FirebaseAuth.instance.currentUser;
  bool load = true;
  bool? havePost;
  var sosPostModels = <SosPostModel>[];
  var userModels = <UserModel>[];
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    docIdFastLink = widget.docIdFastLink;
    readPostData();
  }

  Future<void> readPostData() async {
    FirebaseFirestore.instance
        .collection('fastlink')
        .doc(docIdFastLink)
        .collection('post')
        .orderBy('timePost', descending: true)
        .snapshots()
        .listen((event) async {
      load = false;
      print('listen Work');

      if (sosPostModels.isNotEmpty) {
        sosPostModels.clear();
        userModels.clear();
      }

      if (event.docs.isEmpty) {
        havePost = false;
      } else {
        havePost = true;
        for (var element in event.docs) {
          SosPostModel sosPostModel = SosPostModel.fromMap(element.data());
          sosPostModels.add(sosPostModel);

          UserModel userModel =
              await MyFirebase().findUserModel(uid: sosPostModel.uidPost);
          userModels.add(userModel);
        }
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: LayoutBuilder(builder: (context, BoxConstraints boxConstraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).requestFocus(FocusScopeNode()),
          child: SizedBox(
            width: boxConstraints.maxWidth,
            height: boxConstraints.maxHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                load
                    ? const ShowProgress()
                    : havePost!
                        ? Column(
                            children: [
                              SizedBox(
                                height: boxConstraints.maxHeight - 60,
                                child: ListView.builder(
                                  reverse: true,
                                  itemCount: sosPostModels.length,
                                  itemBuilder: (context, index) => Row(
                                    mainAxisAlignment:
                                        sosPostModels[index].uidPost ==
                                                user!.uid
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                    children: [
                                      sosPostModels[index].uidPost == user!.uid
                                          ? const SizedBox()
                                          : ShowCircleImage(
                                              path: userModels[index].avatar ??
                                                  MyConstant.urlLogo,
                                              pressFunc: () async {
                                                String uidLogin = user!.uid;
                                                String uidPartner =
                                                    sosPostModels[index]
                                                        .uidPost;

                                                String? docIdMessaging =
                                                    await MyFirebase()
                                                        .findDocIdMessaging(
                                                            uidLogin: uidLogin,
                                                            uidParter:
                                                                uidPartner);
                                                print(
                                                    '##28oct uidLigin = $uidLogin, uidPartner = $uidPartner, docIdMessaging = $docIdMessaging');

                                                if (docIdMessaging == null) {
                                                  //Create New DocMessage
                                                  var doubleMessages =
                                                      <String>[];
                                                  doubleMessages.add(uidLogin);
                                                  doubleMessages
                                                      .add(uidPartner);
                                                  MessageingModel
                                                      messageingModel =
                                                      MessageingModel(
                                                          doubleMessages:
                                                              doubleMessages);
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('messaging')
                                                      .doc()
                                                      .set(messageingModel
                                                          .toMap())
                                                      .then((value) async {
                                                    print(
                                                        '##28oct Create DocIdMessage Success');
                                                    //goto Chat Room

                                                    docIdMessaging =
                                                        await MyFirebase()
                                                            .findDocIdMessaging(
                                                                uidLogin:
                                                                    uidLogin,
                                                                uidParter:
                                                                    uidPartner);

                                                    Get.to(ChatRoom(
                                                        docIdMessaging:
                                                            docIdMessaging!));
                                                  });
                                                } else {
                                                  //Use Current DocMessage
                                                  //goto Chat Room
                                                  Get.to(ChatRoom(
                                                      docIdMessaging:
                                                          docIdMessaging));
                                                }
                                              },
                                            ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          sosPostModels[index].post.isEmpty
                                              ? WidgetImageInternet(
                                                  path: sosPostModels[index]
                                                          .urlImagePost ??
                                                      MyConstant.urlLogo,
                                                  width: 200,
                                                  hight: 200,
                                                )
                                              : Container(padding: const EdgeInsets.all(16),
                                                  decoration:
                                                      MyStyle().bgCircleGrey(),
                                                  width: 200,
                                                  child: ShowText(
                                                    label: sosPostModels[index]
                                                        .post,
                                                    textStyle:
                                                        MyStyle().h3Style(),
                                                  ),
                                                ),
                                          ShowText(
                                            label: MyProcess()
                                                .timeStampToString(
                                                    timestamp:
                                                        sosPostModels[index]
                                                            .timePost),
                                            textStyle: MyStyle().h3RedStyle(),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                newPost(boxConstraints: boxConstraints),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget newPost({required BoxConstraints boxConstraints}) {
    return Positioned(
      bottom: 8,
      child: Container(
        decoration: BoxDecoration(color: Colors.grey.shade300),
        width: boxConstraints.maxWidth,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ShowIconButton(
              iconData: Icons.camera,
              pressFunc: () async {
                var result = await MyProcess()
                    .processTakePhoto(source: ImageSource.camera);
                processUploadImage(file: File(result.path));
              },
              color: MyStyle.red,
            ),
            ShowIconButton(
              iconData: Icons.image,
              pressFunc: () async {
                var result = await MyProcess()
                    .processTakePhoto(source: ImageSource.gallery);
                processUploadImage(file: File(result.path));
              },
              color: MyStyle.red,
            ),
            SizedBox(
              width: boxConstraints.maxWidth * 0.5,
              child: ShowFormLong(
                marginTop: 2,
                label: 'ข้อความ',
                fixColor: Colors.white,
                changeFunc: (p0) {
                  post = p0.trim();
                },
                textEditingController: textEditingController,
              ),
            ),
            ShowButton(
              label: 'ส่ง',
              pressFunc: () async {
                if (!(post?.isEmpty ?? true)) {
                  MyDialog(context: context).processDialog();

                  DateTime dateTime = DateTime.now();
                  print(
                      'post ==> $post, uid ==> ${user!.uid}, dateTime ==> $dateTime, docIdSos ==> $docIdFastLink');
                  SosPostModel sosPostModel = SosPostModel(
                      post: post!,
                      uidPost: user!.uid,
                      timePost: Timestamp.fromDate(dateTime));
                  await FirebaseFirestore.instance
                      .collection('fastlink')
                      .doc(docIdFastLink)
                      .collection('post')
                      .doc()
                      .set(sosPostModel.toMap())
                      .then((value) {
                    Navigator.pop(context);
                    post = null;
                    textEditingController.text = '';
                  });
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> processUploadImage({required File file}) async {
    MyDialog(context: context).processDialog();

    String nameFile = '${user!.uid}${Random().nextInt(1000000)}.jpg';
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference reference = storage.ref().child('postdiscovery/$nameFile');
    UploadTask task = reference.putFile(file);
    await task.whenComplete(() async {
      await reference.getDownloadURL().then((value) async {
        String urlImagePost = value;
        print('urlImagePost =====> $urlImagePost');

        SosPostModel sosPostModel = SosPostModel(
          post: '',
          uidPost: user!.uid,
          timePost: Timestamp.fromDate(DateTime.now()),
          urlImagePost: urlImagePost,
        );

        await FirebaseFirestore.instance
            .collection('fastlink')
            .doc(docIdFastLink)
            .collection('post')
            .doc()
            .set(sosPostModel.toMap())
            .then((value) {
          Navigator.pop(context);
        });
      });
    });
  }
}
