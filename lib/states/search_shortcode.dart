// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: avoid_print

import 'dart:async';

import 'package:admanyout/models/linkfriend_model.dart';
import 'package:admanyout/states/base_manage_my_link.dart';
import 'package:admanyout/widgets/show_button.dart';
import 'package:admanyout/widgets/show_image.dart';
import 'package:admanyout/widgets/show_text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
import 'package:admanyout/widgets/show_outline_button.dart';
import 'package:admanyout/widgets/show_text.dart';

class SearchShortCode extends StatefulWidget {
  const SearchShortCode({Key? key}) : super(key: key);

  @override
  State<SearchShortCode> createState() => _SearchShortCodeState();
}

class _SearchShortCodeState extends State<SearchShortCode> {
  String? search;
  TextEditingController controller = TextEditingController();
  bool? statusLoginBool;

  String? addNewLink;
  TextEditingController textEditingController = TextEditingController();

  var fastLinkModels = <FastLinkModel>[];
  var userModels = <UserModel>[];
  var documentLists = <DocumentSnapshot>[];
  var showButtonLinks = <bool>[];
  int lastIndex = 0;

  final globalQRkey = GlobalKey();

  ScrollController scrollController = ScrollController();

  var user = FirebaseAuth.instance.currentUser;

  // AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    checkStatusLogin();
    setupScorllController();
    findDocumentLists();
    readFastLinkData();
  }

  @override
  void dispose() {
    super.dispose();
    // assetsAudioPlayer.dispose();
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
        '##17july lastindex ที่ readFastLinkData หรือเริ่มทำงาน ==> $lastIndex');

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
    print('##17july เริ่มทำงาน readMoreFastLinkData lastIndex ---> $lastIndex');
    print(
        '##17july ขนาดของ documentLists ตรวจที่ readMoreFastLinkData ==>> ${documentLists.length}');

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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: newAppBar(context),
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
                newAddLink(),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget newAddLink() {
    return Positioned(
      bottom: 16,
      child: Container(
        margin: const EdgeInsets.only(left: 24),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BaseManageMyLink(),
                    )).then((value) {
                  print('pop from BaseMenageLink');
                });
              },
              child: const ShowImage(
                path: 'images/logo.png',
                width: 36,
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            ShowForm(
              topMargin: 2,
              prefixWidget: ShowIconButton(
                color: Colors.black,
                iconData: Icons.backspace_outlined,
                pressFunc: () {
                  textEditingController.text = '';
                  setState(() {});
                },
              ),
              colorTheme: Colors.black,
              controller: textEditingController,
              label: 'Add Link',
              iconData: Icons.add_box_outlined,
              colorSuffixIcon: const Color.fromARGB(255, 34, 174, 13),
              changeFunc: (String string) {
                addNewLink = string.trim();
              },
              pressFunc: () {
                if (statusLoginBool!) {
                  if (addNewLink?.isEmpty ?? true) {
                    addNewLink = '';
                  }
                  String sixCode = MyFirebase().getRandom(6);
                  sixCode = '#$sixCode';
                  // assetsAudioPlayer.stop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddFastLink(sixCode: sixCode, addLink: addNewLink!),
                      )).then((value) {
                    // textEditingController.text = '';
                    readFastLinkData();
                  });
                } else {
                  alertLogin(context);
                }
              },
            ),
            ShowIconButton(
              iconData: Icons.play_circle,
              color: Colors.green,
              size: 36,
              pressFunc: () {
                if (addNewLink?.isNotEmpty ?? false) {
                  MyProcess().processLaunchUrl(url: addNewLink!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget formSearchShortCode({required BoxConstraints boxConstraints}) {
    return Column(
      children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     // ShowForm(
        //     //     colorTheme: Colors.black,
        //     //     controller: controller,
        //     //     label: 'กรอก Link ID เพื่อหา Link',
        //     //     iconData: Icons.qr_code,
        //     //     changeFunc: (String string) {
        //     //       search = string.trim();
        //     //     }),
        //     // Container(
        //     //   margin: const EdgeInsets.only(top: 16, left: 4),
        //     //   child: ShowOutlineButton(
        //     //       colorTheme: Colors.black,
        //     //       label: 'OK',
        //     //       pressFunc: () {
        //     //         if (!(search?.isEmpty ?? true)) {
        //     //           processFindSearchFromSixDigi();
        //     //         }
        //     //       }),
        //     // ),
        //   ],
        // ),
        Container(
          // padding: const EdgeInsets.symmetric(horizontal: 8),
          width: boxConstraints.maxWidth,
          height: boxConstraints.maxHeight - 80,
          margin: const EdgeInsets.only(bottom: 16),
          // decoration: BoxDecoration(color: Colors.grey),
          child: fastLinkModels.isEmpty
              ? const SizedBox()
              : LayoutBuilder(builder:
                  (BuildContext context, BoxConstraints boxConstraints) {
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: fastLinkModels.length,
                    itemBuilder: (context, index) {
                      print('##17july lastIndex ที่ listview ---> $lastIndex');
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
          Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                  ),
                  child: Row(
                    children: [
                      ShowCircleImage(
                          radius: 24,
                          path: userModels[index].avatar ?? MyConstant.urlLogo),
                      // const SizedBox(
                      //   width: 4,
                      // ),
                      // ShowText(
                      //   label: userModels[index].name,
                      //   textStyle: MyConstant().h2WhiteBigStyle(),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          (showButtonLinks[index])
              ? ShowButton(
                  label: 'Link',
                  pressFunc: () async {
                    String uidPost = fastLinkModels[index].uidPost;
                    String uidLogin = user!.uid;
                    print(
                        'You Click Link uidPost ===>> $uidPost, uidLogin = $uidLogin');
                    LinkFriendModel linkFriendModel =
                        LinkFriendModel(uidLinkFriend: uidPost);
                    await FirebaseFirestore.instance
                        .collection('user')
                        .doc(uidLogin)
                        .collection('linkfriend')
                        .doc()
                        .set(linkFriendModel.toMap())
                        .then((value) {
                      print('Create LinkFriend Success');
                      readFastLinkData();
                    });
                  })
              : const SizedBox(),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Container(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.75)),
              child: ShowIconButton(
                color: Colors.grey,
                iconData: Icons.more_horiz,
                pressFunc: () async {
                  await Share.share(
                      'https://play.google.com/store/apps/details?id=com.flutterthailand.admanyout ${fastLinkModels[index].linkId}');
                },
              ),
            ),
          ),
          ShowButton(
              label: 'Link ID',
              pressFunc: () {
                processGenQRcode(linkId: fastLinkModels[index].linkId);
              }),
          newContent2(boxConstraints, index),
        ],
      ),
    );
  }

  SizedBox newContent2(BoxConstraints boxConstraints, int index) {
    return SizedBox(
      width: boxConstraints.maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(10)),
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
          ClipRRect(borderRadius: BorderRadius.circular(10),
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
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.75)),
            child: ShowText(
              label:
                  MyProcess().showSource(string: fastLinkModels[index].linkUrl),
              textStyle: MyConstant().h3RedStyle(),
            ),
          ),
        ],
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
      title: InkWell(
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
      ),
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

  void alertLogin(BuildContext context) {
    MyDialog(context: context).normalActionDilalog(
        title: 'No Login ?',
        message: 'Please Login',
        label: 'Login',
        pressFunc: () {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Authen(),
              ));
        });
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
