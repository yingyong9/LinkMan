// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:admanyout/models/comment_model.dart';
import 'package:admanyout/states/main_menu.dart';
import 'package:admanyout/states/noti_fast_photo.dart';
import 'package:admanyout/states/read_qr_code.dart';
import 'package:admanyout/states/room_stream.dart';
import 'package:admanyout/states/youtube_player_video.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/show_elevate_icon_button.dart';
import 'package:admanyout/widgets/show_form.dart';
import 'package:admanyout/widgets/show_image_icon_button.dart';
import 'package:admanyout/widgets/show_image.dart';
import 'package:admanyout/widgets/show_text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:admanyout/models/fast_link_model.dart';
import 'package:admanyout/models/post_model2.dart';
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/states/add_fast_link.dart';
import 'package:admanyout/states/authen.dart';
import 'package:admanyout/states/main_home.dart';
import 'package:admanyout/states/show_detail_post.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/utility/my_process.dart';
import 'package:admanyout/widgets/show_circle_image.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_text.dart';

class SearchShortCode extends StatefulWidget {
  const SearchShortCode({Key? key}) : super(key: key);

  @override
  State<SearchShortCode> createState() => _SearchShortCodeState();
}

class _SearchShortCodeState extends State<SearchShortCode> {
  String? search, addNewLink;
  TextEditingController controller = TextEditingController();
  bool? statusLoginBool;
  TextEditingController textEditingController = TextEditingController();
  var fastLinkModels = <FastLinkModel>[];
  var docIdFastLinks = <String>[];
  var userModels = <UserModel>[];
  var docIdUsers = <String>[];
  var documentLists = <DocumentSnapshot>[];
  var showButtonLinks = <bool>[];
  int lastIndex = 9;
  final globalQRkey = GlobalKey();
  ScrollController scrollController = ScrollController();
  var user = FirebaseAuth.instance.currentUser;
  bool processLoad = false;

  var commentTexts = <String?>[];
  var listCommentModels = <List<CommentModel>>[];
  var listUserModelComments = <List<UserModel>>[];
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkStatusLogin();
    setupScorllController();
    findDocumentLists();
    readFastLinkData();
    openStorageForAndroid();
  }

  Future<void> openStorageForAndroid() async {
    if (Platform.isAndroid) {
      var result = await Permission.storage.status;
      if (result.isDenied) {
        // print('result ==> denied');
        Permission.storage.request();
      }
    }
  }

  Future<void> processAutoMove() async {
    Duration duration = const Duration(seconds: 3);
    Timer(duration, () {
      readMoreFastLinkData();
      processAutoMove();
    });
  }

  void setupScorllController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.minScrollExtent) {
        print('##6Aug Load More on Top');
        MyDialog(context: context).processDialog();
        processLoad = true;
        findDocumentLists();
        readFastLinkData();
      }

      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        print('##6Aug Load More on Button Work');
        MyDialog(context: context).processDialog();
        processLoad = true;
        readMoreFastLinkData();
      }
    });
  }

  Future<void> processPlaySongBg({required String urlSong}) async {
    // await assetsAudioPlayer.open(Audio.network(urlSong));
  }

  Future<void> readFastLinkData() async {
    if (fastLinkModels.isNotEmpty) {
      fastLinkModels.clear();
      userModels.clear();
      documentLists.clear();
      showButtonLinks.clear();
      lastIndex = 9;
      docIdFastLinks.clear();
      listCommentModels.clear();
      commentTexts.clear();
      listUserModelComments.clear();
      docIdUsers.clear();
    }

    print(
        '##17july lastindex ที่ readFastLinkData หรือเริ่มทำงาน ==> $lastIndex');

    await FirebaseFirestore.instance
        .collection('fastlink')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get()
        .then((value) async {
      for (var element in value.docs) {
        FastLinkModel fastLinkModel = FastLinkModel.fromMap(element.data());
        fastLinkModels.add(fastLinkModel);
        docIdFastLinks.add(element.id);
        commentTexts.add(null);

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('user')
              .doc(user!.uid)
              .collection('linkfriend')
              .where('uidLinkFriend', isEqualTo: fastLinkModel.uidPost)
              .get()
              .then((value) {
            if (value.docs.isEmpty) {
              showButtonLinks.add(true);
            } else {
              showButtonLinks.add(false);
            }
          });
        } else {
          showButtonLinks.add(false);
        }

        await MyFirebase()
            .findUserModel(uid: fastLinkModel.uidPost)
            .then((value) {
          userModels.add(value);
        });

        //About Comment
        await FirebaseFirestore.instance
            .collection('fastlink')
            .doc(element.id)
            .collection('comment')
            .orderBy('timeComment')
            .get()
            .then((valueComment) async {
          print('valurComment ==> ${valueComment.docs}');
          if (value.docs.isEmpty) {
            listCommentModels.add([]);
            listUserModelComments.add([]);
          } else {
            var commentModels = <CommentModel>[];
            var userModels = <UserModel>[];
            for (var element in valueComment.docs) {
              CommentModel commentModel = CommentModel.fromMap(element.data());
              commentModels.add(commentModel);

              UserModel userModel = await MyFirebase()
                  .findUserModel(uid: commentModel.uidComment);
              userModels.add(userModel);
            }
            listCommentModels.add(commentModels);
            listUserModelComments.add(userModels);
          }
          print('listCommentamodels ===> $listCommentModels');
        });
      }
      // print('##17july showButtonLinks ===> $showButtonLinks');

      if (processLoad) {
        processLoad = false;
        Navigator.pop(context);
      }

      setState(() {});
    });
  }

  Future<void> readMoreFastLinkData() async {
    print('##17july เริ่มทำงาน readMoreFastLinkData lastIndex ---> $lastIndex');
    print(
        '##17july ขนาดของ documentLists ตรวจที่ readMoreFastLinkData ==>> ${documentLists.length}');

    if (lastIndex + 1 <= documentLists.length) {
      await FirebaseFirestore.instance
          .collection('fastlink')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(documentLists[lastIndex])
          .limit(10)
          .get()
          .then((value) async {
        for (var element in value.docs) {
          FastLinkModel fastLinkModel = FastLinkModel.fromMap(element.data());
          fastLinkModels.add(fastLinkModel);
          docIdFastLinks.add(element.id);
          commentTexts.add(null);

          if (user != null) {
            await FirebaseFirestore.instance
                .collection('user')
                .doc(user!.uid)
                .collection('linkfriend')
                .where('uidLinkFriend', isEqualTo: fastLinkModel.uidPost)
                .get()
                .then((value) {
              if (value.docs.isEmpty) {
                showButtonLinks.add(true);
              } else {
                showButtonLinks.add(false);
              }
            });
          } else {
            showButtonLinks.add(false);
          }

          await MyFirebase()
              .findUserModel(uid: fastLinkModel.uidPost)
              .then((value) {
            userModels.add(value);
          });

          //About Comment
          await FirebaseFirestore.instance
              .collection('fastlink')
              .doc(element.id)
              .collection('comment')
              .orderBy('timeComment')
              .get()
              .then((valueComment) async {
            if (valueComment.docs.isEmpty) {
              listCommentModels.add([]);
              listUserModelComments.add([]);
            } else {
              var commentModels = <CommentModel>[];
              var userModels = <UserModel>[];
              for (var element in valueComment.docs) {
                CommentModel commentModel =
                    CommentModel.fromMap(element.data());
                commentModels.add(commentModel);

                UserModel userModel = await MyFirebase()
                    .findUserModel(uid: commentModel.uidComment);
                userModels.add(userModel);
              }
              listCommentModels.add(commentModels);
              listUserModelComments.add(userModels);
            }

            print('listCommentamodels at More Fast ===> $listCommentModels');
          });
        }
        lastIndex++;
        print('##20july นี่คือ lastIndex ที่โหลดมาใหม่ ===>>> $lastIndex');

        if (processLoad) {
          processLoad = false;
          Navigator.pop(context);
        }

        setState(() {});
      });
    }
  }

  Future<void> findDocumentLists() async {
    await FirebaseFirestore.instance
        .collection('fastlink')
        .orderBy('timestamp', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        documentLists.add(element);
      }
      print('##9july ขนาดของ documentLists ==>> ${documentLists.length}');
    });
  }

  Future<void> checkStatusLogin() async {
    FirebaseAuth.instance.authStateChanges().listen((event) {
      if (event == null) {
        statusLoginBool = false;
      } else {
        statusLoginBool = true;
        setupMessaging();
      }
    });
  }

  Future<void> setupMessaging() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String? token = await firebaseMessaging.getToken();
    if (token != null) {
      print('##19sep token ==> $token');
      await MyFirebase().updateToken(uid: user!.uid, token: token);
    }

    FirebaseMessaging.onMessage.listen((event) {
      String? title = event.notification!.title;
      String? body = event.notification!.body;
      MyDialog(context: context).normalActionDilalog(
        title: title!,
        message: body!,
        label: 'ถ่ายรูป ร่วมสนุกกับ เพื่อนๆของคุณ',
        pressFunc: () {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotiFastPhoto(),
              ));
        },
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      String? title = event.notification!.title;
      String? body = event.notification!.body;
      MyDialog(context: context).normalActionDilalog(
        title: title!,
        message: body!,
        label: 'ถ่ายรูป ร่วมสนุกกับ เพื่อนๆของคุณ',
        pressFunc: () {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotiFastPhoto(),
              ));
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).requestFocus(FocusScopeNode()),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints boxConstraints) {
          return SizedBox(
            width: boxConstraints.maxWidth,
            height: boxConstraints.maxHeight,
            child: Stack(
              children: [
                formSearchShortCode(boxConstraints: boxConstraints),
                newAddLink(boxConstraints: boxConstraints),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget newAddLink({required BoxConstraints boxConstraints}) {
    return Positioned(
      bottom: 0,
      child: Container(
        width: boxConstraints.maxWidth - 20,
        // color: Colors.green,
        margin: const EdgeInsets.only(left: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShowIconButton(
              iconData: Icons.search_outlined,
              size: 24,
              pressFunc: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReadQRcode(),
                    ));
              },
            ),
            InkWell(
              onTap: () {
                if (statusLoginBool!) {
                  if (addNewLink?.isEmpty ?? true) {
                    addNewLink = '';
                  }
                  String sixCode = MyFirebase().getRandom(6);
                  sixCode = '#$sixCode';
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddFastLink(sixCode: sixCode, addLink: addNewLink!),
                      ),
                      (route) => false);
                } else {
                  alertLogin(context);
                }
              },
              child: const ShowImage(
                path: 'images/addboxwhite.png',
                width: 24,
              ),
            ),
            // ShowIconButton(
            //   iconData: Icons.video_camera_back_outlined,
            //   size: 36,
            //   pressFunc: () {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => const RoomStream(),
            //         ));
            //   },
            // ),
            // ShowIconButton(
            //   size: 36,
            //   iconData: Icons.language_outlined,
            //   pressFunc: () {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => const ManageMeeting(),
            //         ));
            //   },
            // ),
            // const SizedBox(
            //   width: 8,
            // ),
            InkWell(
              onTap: () {
                if (statusLoginBool!) {
                  // MyDialog(context: context).buttonSheetDialog();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainMenu(),
                      ));
                } else {
                  alertLogin(context);
                }
              },
              child: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget formSearchShortCode({required BoxConstraints boxConstraints}) {
    return Column(
      children: [
        Container(
          width: boxConstraints.maxWidth,
          height: boxConstraints.maxHeight - 45,
          margin: const EdgeInsets.only(bottom: 16),
          child: fastLinkModels.isEmpty
              ? const SizedBox()
              : LayoutBuilder(builder:
                  (BuildContext context, BoxConstraints boxConstraints) {
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: fastLinkModels.length,
                    itemBuilder: (context, index) {
                      String urlSong = fastLinkModels[lastIndex].urlSong;
                      if (urlSong.isNotEmpty) {
                        processPlaySongBg(urlSong: urlSong);
                      }

                      return InkWell(
                        onTap: () async {
                          String linkUrl = fastLinkModels[index].linkUrl;
                          if (linkUrl.contains('#')) {
                            search = fastLinkModels[index].linkUrl;
                            processFindShortCode();
                          } else {
                            String urlLauncher = fastLinkModels[index].linkUrl;
                            print('urlLauncher ==> $urlLauncher');
                            await MyProcess()
                                .processLaunchUrl(url: urlLauncher);
                          }
                        },
                        child: Card(
                          child: Stack(
                            children: [
                              newImageListView(boxConstraints, index),
                              listComment(boxConstraints, index, context),
                              // fourButton(),
                              showOwnerPost(index),
                              // newContent1(boxConstraints, index),
                              // newContent3(boxConstraints, index),
                              // newContent4(index),
                              // newContent5(index),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
        ),
      ],
    );
  }

  Container showOwnerPost(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: MyStyle().bgCircleBlack(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShowCircleImage(
            path: userModels[index].avatar!,
            radius: 18,
          ),
          const SizedBox(
            width: 8,
          ),
          ShowText(
            label: userModels[index].name,
            textStyle: MyStyle().h3WhiteBoldStyle(),
          ),
          ShowIconButton(
            iconData: Icons.group,
            pressFunc: () {},
          )
        ],
      ),
    );
  }

  Positioned fourButton() {
    return Positioned(
      bottom: 80,
      right: 20,
      child: Column(
        children: [
          ShowIconButton(
            color: Colors.red,
            iconData: Icons.radio_button_checked,
            pressFunc: () {},
          ),
          ShowIconButton(
            color: Colors.red,
            iconData: Icons.radio_button_checked,
            pressFunc: () {},
          ),
          ShowIconButton(
            color: Colors.red,
            iconData: Icons.radio_button_checked,
            pressFunc: () {},
          ),
          ShowIconButton(
            color: Colors.red,
            iconData: Icons.radio_button_checked,
            pressFunc: () {},
          ),
        ],
      ),
    );
  }

  Widget listComment(
      BoxConstraints boxConstraints, int index, BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.2)),
        width: boxConstraints.maxWidth,
        // height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            listCommentModels[index].isEmpty
                ? const SizedBox()
                : Container(
                    constraints: BoxConstraints(
                        maxHeight: boxConstraints.maxHeight * 0.3),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemCount: listCommentModels[index].length,
                      itemBuilder: (context, index2) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 16),
                                child: ShowCircleImage(
                                    radius: 16,
                                    path: listUserModelComments[index][index2]
                                        .avatar!),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                decoration: MyStyle().bgCircleGrey(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShowText(
                                      label: listUserModelComments[index]
                                              [index2]
                                          .name,
                                      textStyle: MyStyle().h3GreenBoldStyle(),
                                    ),
                                    Container(
                                      constraints: BoxConstraints(
                                          maxWidth:
                                              boxConstraints.maxWidth * 0.6),
                                      child: ShowText(
                                        label:
                                            '${listCommentModels[index][index2].comment}   ${MyProcess().timeStampToString(timestamp: listCommentModels[index][index2].timeComment)}',
                                        textStyle: MyStyle().h3WhiteBoldStyle(),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ShowForm(
                  width: boxConstraints.maxWidth * 0.6,
                  controller: textEditingController,
                  fillColor: Colors.grey.withOpacity(0.8),
                  topMargin: 0,
                  label: 'แสดงความคิดเห็น',
                  iconData: Icons.send,
                  changeFunc: (p0) async {
                    commentTexts[index] = p0;
                  },
                  pressFunc: () async {
                    DateTime dateTime = DateTime.now();
                    Timestamp timestamp = Timestamp.fromDate(dateTime);

                    if (!(commentTexts[index]?.isEmpty ?? true)) {
                      CommentModel commentModel = CommentModel(
                          comment: commentTexts[index]!,
                          timeComment: timestamp,
                          uidComment: user!.uid);
                      await FirebaseFirestore.instance
                          .collection('fastlink')
                          .doc(docIdFastLinks[index])
                          .collection('comment')
                          .doc()
                          .set(commentModel.toMap())
                          .then((value) async {
                        print('Add Comment success');

                        textEditingController.text = '';
                        commentTexts[index] = '';

                        listCommentModels[index].add(commentModel);
                        UserModel userModel =
                            await MyFirebase().findUserModel(uid: user!.uid);
                        listUserModelComments[index].add(userModel);
                        setState(() {});

                        // if (index == 0) {

                        //   MyDialog(context: context).processDialog();
                        //   processLoad = true;
                        //   findDocumentLists();
                        //   readFastLinkData();
                        // } else {
                        //   print('index ที่เพิ่ม Commemt ==> $index');
                        //   listCommentModels[index].add(commentModel);
                        //   UserModel userModel =
                        //       await MyFirebase().findUserModel(uid: user!.uid);
                        //   listUserModelComments[index].add(userModel);
                        //   setState(() {});
                        // }
                      });
                    } // if
                  },
                ),
                //  Padding(
                //   padding: const EdgeInsets.only(right: 16, left: 16),
                //   child: ShowImageIconButton(
                //     path: 'images/message.png',
                //     pressFunc: () {
                //       if (fastLinkModels[index].linkContact.isNotEmpty) {
                //         String urlSave = fastLinkModels[index].urlImage;
                //         processSaveQRcodeOnStorage(urlImage: urlSave);

                //         MyProcess().processLaunchUrl(
                //             url: fastLinkModels[index].linkContact);
                //       }
                //     },
                //   ),
                // ),
              ],
            ),
            fastLinkModels[index].urlProduct.isEmpty
                ? const SizedBox()
                : InkWell(
                    onTap: () async {
                      String linkProduct = fastLinkModels[index].linkContact;
                      print('linkProduct ===> $linkProduct');
                      if (linkProduct.isNotEmpty) {
                        await MyProcess().processLaunchUrl(url: linkProduct);
                      }

                      processSave(
                          urlSave: fastLinkModels[index].urlProduct,
                          nameFile: 'product${Random().nextInt(1000)}.jpg');
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: MyStyle.bgColor),
                      width: boxConstraints.maxWidth * 0.6,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: boxConstraints.maxWidth * 0.2,
                            height: boxConstraints.maxWidth * 0.2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network(
                                fastLinkModels[index].urlProduct,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(
                              width: (boxConstraints.maxWidth * 0.6) -
                                  (boxConstraints.maxWidth * 0.2),
                              child: ShowText(
                                label: fastLinkModels[index].head,
                                textStyle: MyStyle().h2Style(),
                              ))
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget newContent5(int index) {
    return fastLinkModels[index].position == const GeoPoint(0, 0)
        ? const SizedBox()
        : navPosition(geoPoint: fastLinkModels[index].position);
  }

  Widget newContent4(int index) {
    return fastLinkModels[index].linkContact.isEmpty
        ? const SizedBox()
        : Positioned(
            bottom: 64,
            left: 16,
            child: ShowElevateButton(
              label: fastLinkModels[index].nameButtonLinkContact.isEmpty
                  ? 'LinkContact'
                  : fastLinkModels[index].nameButtonLinkContact,
              pressFunc: () {
                MyProcess()
                    .processLaunchUrl(url: fastLinkModels[index].linkContact);
              },
              iconData: Icons.shopping_basket_outlined,
            ),
          );
  }

  Positioned newContent3(BoxConstraints boxConstraints, int index) {
    return Positioned(
      bottom: 30,
      left: 10,
      child: SizedBox(
        width: boxConstraints.maxWidth - 36,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            iconSaveImage(index),
            showDialogGenQRcode(index),
            iconShare(index),
            const ShowText(label: '999'),
            iconFavorite(index: index),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                ShowText(
                  label: userModels[index].name,
                  textStyle: MyConstant().h2WhiteStyle(),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 207, 18, 5)),
                  child: const ShowText(label: 'ติดตาม'),
                ),
                const SizedBox(
                  width: 8,
                ),
                const ShowText(label: '999 คน'),
                showTextSourceLink(index),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Positioned navPosition({required GeoPoint geoPoint}) {
    double lat = geoPoint.latitude;
    double lng = geoPoint.longitude;

    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    return Positioned(
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShowIconButton(
            size: 36,
            iconData: Icons.pin_drop_outlined,
            pressFunc: () {
              MyProcess().processLaunchUrl(url: googleUrl);
            },
          ),
          ShowText(
            label: 'นำทาง',
            textStyle: MyStyle().h3WhiteStyle(),
          )
        ],
      ),
    );
  }

  ShowIconButton iconFavorite({required int index}) {
    return ShowIconButton(
      size: 36,
      color: const Color.fromARGB(255, 197, 20, 7),
      iconData: Icons.favorite,
      pressFunc: () async {
        print('##31july docIdFastLink ==> ${docIdFastLinks[index]}');
        print('##31july uid login ==>> ${user!.uid}');

        await FirebaseFirestore.instance
            .collection('fastlink')
            .doc(docIdFastLinks[index])
            .collection('favorite')
            .where('uidfavorite', isEqualTo: user!.uid)
            .get()
            .then((value) async {
          print('##31july value favorite ---> ${value.docs}');

          if (value.docs.isEmpty) {
            // allow favorite

            Map<String, dynamic> map = {};
            map['uidfavorite'] = user!.uid;

            await FirebaseFirestore.instance
                .collection('fastlink')
                .doc(docIdFastLinks[index])
                .collection('favorite')
                .doc()
                .set(map)
                .then((value) {
              print('##31july Success add Favorite');
            });
          } else {
            // unallow favoite

            for (var element in value.docs) {
              String docFavorite = element.id;
              print('##31july docFavorite ===>> $docFavorite');

              await FirebaseFirestore.instance
                  .collection('fastlink')
                  .doc(docIdFastLinks[index])
                  .collection('favorite')
                  .doc(docFavorite)
                  .delete()
                  .then((value) {
                print('##31july Delete Favorite');
              });
            }
          }
        });
      },
    );
  }

  Widget iconSaveImage(int index) {
    return Container(
      // decoration: MyConstant().curveBorderBox(curve: 30, color: Colors.white),
      child: ShowIconButton(
        size: 36,
        iconData: Icons.save,
        pressFunc: () {
          String urlSave = fastLinkModels[index].urlImage;
          processSaveQRcodeOnStorage(urlImage: urlSave);
        },
      ),
    );
  }

  Widget showDialogGenQRcode(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      // decoration: MyConstant().curveBorderBox(curve: 30, color: Colors.white),
      child: ShowIconButton(
        size: 36,
        iconData: Icons.qr_code,
        color: Colors.white,
        pressFunc: () {
          processGenQRcode(linkId: fastLinkModels[index].linkId);
        },
      ),
    );
  }

  Widget iconShare(int index) {
    return Container(
      // decoration: MyConstant().curveBorderBox(curve: 30, color: Colors.white),
      child: ShowIconButton(
        size: 36,
        color: Colors.white,
        iconData: Icons.more_vert,
        pressFunc: () async {
          await Share.share(
              'https://play.google.com/store/apps/details?id=com.flutterthailand.admanyout ${fastLinkModels[index].linkId}');
        },
      ),
    );
  }

  Widget newContent1(BoxConstraints boxConstraints, int index) {
    return SizedBox(
      width: boxConstraints.maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 32,
          ),
          newContent2(boxConstraints, index),
        ],
      ),
    );
  }

  Row whoPost(int index) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShowCircleImage(
                radius: 24,
                path: userModels[index].avatar ?? MyConstant.urlLogo),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ],
    );
  }

  SizedBox newContent2(BoxConstraints boxConstraints, int index) {
    return SizedBox(
      width: boxConstraints.maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 8,
          ),
          const SizedBox(
            height: 8,
          ),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Container(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.75)),
              child: ShowText(
                label: fastLinkModels[index].head,
                textStyle: MyConstant().h2BlackStyle(),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.75)),
              child: ShowText(
                label: fastLinkModels[index].detail,
                textStyle: MyConstant().h3BlackStyle(),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.75)),
            child: ShowText(
              label: MyProcess()
                  .cutWord(string: fastLinkModels[index].detail2, word: 50),
              textStyle: MyConstant().h3BlackStyle(),
            ),
          ),
        ],
      ),
    );
  }

  Container showTextSourceLink(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      decoration: BoxDecoration(color: Color.fromARGB(255, 194, 18, 5)),
      child: ShowText(
        label: MyProcess().showSource(string: fastLinkModels[index].linkUrl),
        textStyle: MyConstant().h3WhiteStyle(),
      ),
    );
  }

  SizedBox newImageListView(BoxConstraints boxConstraints, int index) {
    return SizedBox(
      height: boxConstraints.maxHeight,
      // width: boxConstraints.maxWidth * 0.7 - 16,
      width: boxConstraints.maxWidth,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            fastLinkModels[index].urlImage,
            fit: BoxFit.cover,
          ),
          fastLinkModels[index].urlImage2.isEmpty
              ? const SizedBox()
              : Stack(
                  children: [
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image:
                                NetworkImage(fastLinkModels[index].urlImage2),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Future<void> processFindShortCode() async {
    await FirebaseFirestore.instance
        .collection('post2')
        .where('shortcode', isEqualTo: search)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        for (var element in value.docs) {
          PostModel2 postModel2 = PostModel2.fromMap(element.data());
          // print('postModel2 ===> ${postModel2.toMap()}');
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShowDetailPost(postModel2: postModel2),
              ));
        }
        controller.text = '';
      } else {
        Fluttertoast.showToast(
            toastLength: Toast.LENGTH_LONG,
            msg: 'No $search in ShortCode',
            textColor: const Color.fromARGB(255, 236, 12, 12));
      }
    });
  }

  AppBar newAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: textLINKMAN(context),
      // actions: [
      //   ShowIconButton(
      //     size: 36,
      //     color: const Color.fromARGB(255, 236, 12, 12),
      //     iconData: Icons.add_box_outlined,
      //     pressFunc: () {
      //       if (statusLoginBool!) {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             // builder: (context) => const AddPhoto(),
      //             builder: (context) => const AddPhotoMulti(),
      //           ),
      //         );
      //       } else {
      //         alertLogin(context);
      //       }
      //     },
      //   ),
      // ],
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    );
  }

  InkWell textLINKMAN(BuildContext context) {
    return InkWell(
      onTap: () {
        if (statusLoginBool!) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MainHome(),
              ));
        } else {
          alertLogin(context);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShowText(
            label: 'LINKMAN',
            textStyle: MyConstant().h1GreenStyle(),
          ),
          const SizedBox(
            width: 16,
          ),
          ShowIconButton(
            iconData: Icons.search,
            color: Colors.black,
            size: 36,
            pressFunc: () {},
          ),
        ],
      ),
    );
  }

  void alertLogin(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Authen(),
        ));

    // MyDialog(context: context).normalActionDilalog(
    //     title: 'No Login ?',
    //     message: 'Please Login',
    //     label: 'Login',
    //     pressFunc: () {
    //       Navigator.pop(context);
    //       Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //             builder: (context) => const Authen(),
    //           ));
    //     });
  }

  Future<void> processGenQRcode({required String linkId}) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RepaintBoundary(
                    key: globalQRkey,
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: QrImage(data: linkId),
                    ),
                  ),
                  ShowText(
                    label: linkId,
                    textStyle: MyConstant().h3ActionPinkStyle(),
                  ),
                ],
              ),
              actions: [
                ShowTextButton(
                    label: 'Save',
                    pressFunc: () {
                      Navigator.pop(context);
                      processSaveQRcodeOnStorage(qrGen: linkId);
                    })
              ],
            ));
  }

  Future<void> processFindSearchFromSixDigi() async {
    await FirebaseFirestore.instance
        .collection('fastlink')
        .where('linkId', isEqualTo: search)
        .get()
        .then((value) async {
      if (value.docs.isEmpty) {
        Fluttertoast.showToast(msg: 'No Result for $search');
      } else {
        for (var element in value.docs) {
          FastLinkModel fastLinkModel = FastLinkModel.fromMap(element.data());

          String linkUrl = fastLinkModel.linkUrl;
          if (linkUrl.contains('#')) {
            search = fastLinkModel.linkUrl;
            processFindShortCode();
          } else {
            String urlLauncher = fastLinkModel.linkUrl;

            if (urlLauncher.isNotEmpty) {
              await MyProcess().processLaunchUrl(url: urlLauncher);
            }
          }
        }
      }
    });
  }

  Future<void> processSaveQRcodeOnStorage(
      {String? qrGen, String? urlImage}) async {
    print('##26july qrGen ที่ต้องการสร้าง ---> $qrGen');

    if (qrGen != null) {
      String nameFile = qrGen.substring(1);

      String pathQrcode =
          'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=%23$nameFile';

      processSave(urlSave: pathQrcode, nameFile: '$qrGen.png');
    } else if (urlImage != null) {
      processSave(
          urlSave: urlImage, nameFile: 'image${Random().nextInt(1000)}.png');
    }
  }

  Future<void> processSave(
      {required String urlSave, required String nameFile}) async {
    var response = await Dio()
        .get(urlSave, options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(response.data),
      quality: 60,
      name: nameFile,
    );
    if (result['isSuccess']) {
      Fluttertoast.showToast(msg: 'Save Success');
    } else {
      Fluttertoast.showToast(msg: 'Cannot Save QrCode');
    }
  }
}

class Dbouncer {
  final int millisecond;
  Timer? timer;
  VoidCallback? callback;

  Dbouncer({
    required this.millisecond,
  });

  run(VoidCallback callback) {
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer(Duration(milliseconds: millisecond), callback);
  }
}
