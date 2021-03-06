// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:admanyout/states/read_qr_code.dart';
import 'package:admanyout/widgets/show_image.dart';
import 'package:admanyout/widgets/show_text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:admanyout/widgets/show_form.dart';
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
  var userModels = <UserModel>[];
  var documentLists = <DocumentSnapshot>[];
  var showButtonLinks = <bool>[];
  int lastIndex = 0;
  final globalQRkey = GlobalKey();
  ScrollController scrollController = ScrollController();
  var user = FirebaseAuth.instance.currentUser;

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
    await Timer(duration, () {
      readMoreFastLinkData();
      processAutoMove();
    });
  }

  void setupScorllController() {
    
    print('##17july setupScorellController work');
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.minScrollExtent) {
        print('##9july Load More on Top');
        findDocumentLists();
        readFastLinkData();
      }

      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        print('17july Load More on Button Work');
        // assetsAudioPlayer.stop();
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
      lastIndex = 0;
    }

    print(
        '##17july lastindex ????????? readFastLinkData ?????????????????????????????????????????? ==> $lastIndex');

    await FirebaseFirestore.instance
        .collection('fastlink')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get()
        .then((value) async {
      for (var element in value.docs) {
        
        FastLinkModel fastLinkModel = FastLinkModel.fromMap(element.data());
        fastLinkModels.add(fastLinkModel);

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
      }
      print('##17july showButtonLinks ===> $showButtonLinks');
      setState(() {});
    });
  }

  Future<void> readMoreFastLinkData() async {
    print('##17july ?????????????????????????????? readMoreFastLinkData lastIndex ---> $lastIndex');
    print(
        '##17july ????????????????????? documentLists ????????????????????? readMoreFastLinkData ==>> ${documentLists.length}');

    if (lastIndex + 1 <= documentLists.length) {
      await FirebaseFirestore.instance
          .collection('fastlink')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(documentLists[lastIndex])
          .limit(1)
          .get()
          .then((value) async {
        for (var element in value.docs) {
          FastLinkModel fastLinkModel = FastLinkModel.fromMap(element.data());
          fastLinkModels.add(fastLinkModel);

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
        }
        lastIndex++;
        print('##20july ?????????????????? lastIndex ??????????????????????????????????????? ===>>> $lastIndex');
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
      print('##9july ????????????????????? documentLists ==>> ${documentLists.length}');
    });
  }

  Future<void> checkStatusLogin() async {
    FirebaseAuth.instance.authStateChanges().listen((event) {
      if (event == null) {
        statusLoginBool = false;
      } else {
        statusLoginBool = true;
      }
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
        margin: const EdgeInsets.only(left: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReadQRcode(),
                    ));
              },
              child: const ShowImage(
                path: 'images/qr1.png',
                width: 36,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            ShowForm(
              width: boxConstraints.maxWidth - 145,
              topMargin: 2,
              prefixWidget: ShowIconButton(
                iconData: Icons.play_circle,
                color: Colors.white,
                pressFunc: () {
                  if (addNewLink?.isNotEmpty ?? false) {
                    MyProcess().processLaunchUrl(url: addNewLink!);
                  }
                },
              ),
              controller: textEditingController,
              label: 'Add Link',
              iconData: Icons.add_box_outlined,
              colorSuffixIcon: Colors.black,
              changeFunc: (String string) {
                addNewLink = string.trim();
              },
            ),
            ShowIconButton(
              iconData: Icons.add_box_outlined,
              pressFunc: () {
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
            ),
            const SizedBox(
              width: 8,
            ),
            InkWell(
              onTap: () {
                if (statusLoginBool!) {
                  MyDialog(context: context).buttonSheetDialog();
                } else {
                  alertLogin(context);
                }
              },
              child: const Icon(
                Icons.arrow_back_ios_new,
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
                      print('##17july lastIndex ????????? listview ---> $lastIndex');
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
                              newContent1(boxConstraints, index),
                              Positioned(
                                bottom: 30,
                                left: 10,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    iconSaveImage(index),
                                    showDialogGenQRcode(index),
                                    iconShare(index),
                                    ShowText(
                                        label: fastLinkModels[index].favorite!),
                                    iconFavorite(index: index),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      children: [
                                        whoPost(index),
                                        SizedBox(
                                          width: boxConstraints.maxWidth * 0.3,
                                        ),
                                        showTextSourceLink(index),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        ShowText(
                                          label: userModels[index].name,
                                          textStyle:
                                              MyConstant().h2WhiteStyle(),
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(left: 10),
                                          decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 207, 18, 5)),
                                          child:
                                              const ShowText(label: '??????????????????'),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        const ShowText(label: '999 ??????')
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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

  ShowIconButton iconFavorite({required int index}) {
    return ShowIconButton(
      size: 36,
      color: const Color.fromARGB(255, 197, 20, 7),
      iconData: Icons.favorite,
      pressFunc: () {
        int favoriteInt = int.parse(fastLinkModels[index].favorite!);
        favoriteInt++;
       
        print('favoiteInt ==> $favoriteInt, ???????????? ????????? docId == > ${documentLists.length}');
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
      child: Image.network(
        fastLinkModels[index].urlImage,
        fit: BoxFit.cover,
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
    print('##26july qrGen ????????????????????????????????????????????? ---> $qrGen');

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
