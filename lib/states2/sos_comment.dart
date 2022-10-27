// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:math';

import 'package:admanyout/models/sos_post_model.dart';
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/utility/my_constant.dart';
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
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:image_picker/image_picker.dart';

class SosComment extends StatefulWidget {
  final String docIdSos;
  const SosComment({
    Key? key,
    required this.docIdSos,
  }) : super(key: key);

  @override
  State<SosComment> createState() => _SosCommentState();
}

class _SosCommentState extends State<SosComment> {
  String? post, docIdSos;
  var user = FirebaseAuth.instance.currentUser;
  bool load = true;
  bool? havePost;
  var sosPostModels = <SosPostModel>[];
  var userModels = <UserModel>[];
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    docIdSos = widget.docIdSos;
    readPostData();
  }

  Future<void> readPostData() async {
    FirebaseFirestore.instance
        .collection('sos')
        .doc(docIdSos)
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
                                child: ListView.builder(reverse: true,
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
                                                  MyConstant.urlLogo),
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
                                              : ShowText(
                                                  label:
                                                      sosPostModels[index].post,
                                                  textStyle:
                                                      MyStyle().h3Style(),
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
      child: SizedBox(
        width: boxConstraints.maxWidth,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                label: 'ข้อความ',
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
                  DateTime dateTime = DateTime.now();
                  print(
                      'post ==> $post, uid ==> ${user!.uid}, dateTime ==> $dateTime, docIdSos ==> $docIdSos');
                  SosPostModel sosPostModel = SosPostModel(
                      post: post!,
                      uidPost: user!.uid,
                      timePost: Timestamp.fromDate(dateTime));
                  await FirebaseFirestore.instance
                      .collection('sos')
                      .doc(docIdSos)
                      .collection('post')
                      .doc()
                      .set(sosPostModel.toMap())
                      .then((value) {
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
    String nameFile = '${user!.uid}${Random().nextInt(1000000)}.jpg';
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference reference = storage.ref().child('postsos/$nameFile');
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
            .collection('sos')
            .doc(docIdSos)
            .collection('post')
            .doc()
            .set(sosPostModel.toMap())
            .then((value) {
          print('upload image success');
        });
      });
    });
  }
}
