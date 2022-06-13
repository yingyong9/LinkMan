// ignore_for_file: avoid_print

import 'package:admanyout/models/follow_model.dart';
import 'package:admanyout/models/link_model.dart';
import 'package:admanyout/models/post_model2.dart';
import 'package:admanyout/models/special_model.dart';
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/states/add_photo_multi.dart';
import 'package:admanyout/states/authen.dart';
import 'package:admanyout/states/base_manage_my_link.dart';
import 'package:admanyout/states/edit_profile.dart';
import 'package:admanyout/states/key_special.dart';
import 'package:admanyout/states/manage_my_post.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_button.dart';
import 'package:admanyout/widgets/show_circle_image.dart';
import 'package:admanyout/widgets/show_form.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_image.dart';
import 'package:admanyout/widgets/show_outline_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MainHome extends StatefulWidget {
  const MainHome({Key? key}) : super(key: key);

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  var user = FirebaseAuth.instance.currentUser;
  var postModels = <PostModel2>[];
  var docIdPosts = <String>[];
  var bolFollows = <bool>[];
  var userModelPosts = <UserModel>[];
  bool load = true;
  var titles = <String>['แก้ไขโปรไฟร์', 'Sign Out'];
  String? title, token;
  UserModel? userModelLogin;
  ScrollController scrollController = ScrollController();
  bool openProgress = false;
  String? newLink;
  String? nameLink;
  TextEditingController addLinkController = TextEditingController();
  bool displayIconButton = false;

  var documentLists = <DocumentSnapshot>[];

  int factor = 0;

  @override
  void initState() {
    super.initState();

    findUserModelLogin();
    readPost();
    processMessageing();
    setupScorllController();
    findDocumentLists();
  }

  Future<void> findDocumentLists() async {
    await FirebaseFirestore.instance
        .collection('post')
        .orderBy('timePost', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        documentLists.add(element);
      }
      print('ขนาดของ documentLists ==>> ${documentLists.length}');
    });
  }

  void setupScorllController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.minScrollExtent) {
        print('Load More on Top');
        readPost();
      }

      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        print('## Load More on Botton');
        readMorePost();
        factor++;
      }
    });
  }

  Future<void> processMessageing() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    token = await firebaseMessaging.getToken();
    print('token ==>> $token');

    Map<String, dynamic> data = {};
    data['token'] = token;

    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .update(data)
        .then((value) {
      print('UPdate Token Success');
    });

    FirebaseMessaging.onMessage.listen((event) {
      print('OnMessage Work');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print('onOpenApp Work');
    });
  }

  Future<void> findUserModelLogin() async {
    userModelLogin = await MyFirebase().findUserModel(uid: user!.uid);
  }

  Future<void> readPost() async {
    if (postModels.isNotEmpty) {
      postModels.clear();
      docIdPosts.clear();
      bolFollows.clear();
      userModelPosts.clear();
      load = true;
      setState(() {});
    }

    await FirebaseFirestore.instance
        .collection('post2')
        .orderBy('timePost', descending: true)
        // .limit(10)
        .get()
        .then((value) async {
      // print('##10june value ==> ${value.docs}');
      for (var item in value.docs) {
        PostModel2 postModel = PostModel2.fromMap(item.data());
        // print('##10june postmodel ==> ${postModel.toMap()}');

        postModels.add(postModel);
        docIdPosts.add(item.id);

        UserModel userModel =
            await MyFirebase().findUserModel(uid: postModel.uidPost);
        userModelPosts.add(userModel);

        String uidOwnPost = postModel.uidPost;
        String uidLogin = user!.uid;
        await FirebaseFirestore.instance
            .collection('user')
            .doc(uidOwnPost)
            .collection('follow')
            .doc(uidLogin)
            .get()
            .then((value) {
          bool result;
          if (value.data() == null) {
            // ยังไม่ได้ follow
            result = false;
          } else {
            // follow แล่้ว
            result = true;
          }

          bolFollows.add(result);
        });
      }

      if (openProgress) {
        openProgress = false;
        Navigator.pop(context);
      }

      load = false;
      setState(() {});
    });
  }

  Future<void> readMorePost() async {
    if (factor * 10 + 10 <= documentLists.length) {
      await FirebaseFirestore.instance
          .collection('post')
          .orderBy('timePost', descending: true)
          .startAfterDocument(documentLists[10 * factor])
          .limit(10)
          .get()
          .then((value) async {
        for (var item in value.docs) {
          PostModel2 postModel = PostModel2.fromMap(item.data());
          postModels.add(postModel);
          docIdPosts.add(item.id);

          UserModel userModel =
              await MyFirebase().findUserModel(uid: postModel.uidPost);
          userModelPosts.add(userModel);

          String uidOwnPost = postModel.uidPost;
          String uidLogin = user!.uid;
          await FirebaseFirestore.instance
              .collection('user')
              .doc(uidOwnPost)
              .collection('follow')
              .doc(uidLogin)
              .get()
              .then((value) {
            bool result;
            if (value.data() == null) {
              // ยังไม่ได้ follow
              result = false;
            } else {
              // follow แล่้ว
              result = true;
            }

            bolFollows.add(result);
          });
        }

        load = false;
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: newAppBar(context),
      body: load
          ? const ShowProgress()
          : LayoutBuilder(builder: (context, constraints) {
              return Stack(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    controller: scrollController,
                    itemCount: postModels.length,
                    itemBuilder: (context, index) => Column(
                      children: [
                        newRowUp(constraints, index, context),
                        newDiaplayImage(constraints, index),
                        newRowDown(constraints, index),
                        const SizedBox(
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                  controlAddLink(constraints),
                ],
              );
            }),
    );
  }

  Positioned controlAddLink(BoxConstraints constraints) {
    return Positioned(
      bottom: 0,
      child: Container(
        width: constraints.maxWidth,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShowIconButton(
                iconData: Icons.link_outlined,
                pressFunc: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BaseManageMyLink(),
                      ));
                }),
            ShowForm(
              controller: addLinkController,
              label: 'Add Link',
              iconData: Icons.arrow_forward_ios,
              changeFunc: (String string) {
                newLink = string.trim();
              },
              pressFunc: () async {
                checkLink();
              },
            ),
            ShowIconButton(
                iconData: Icons.camera,
                pressFunc: () {
                  // final intent = AndroidIntent(
                  //   package: "com.android.camera",
                  //   action: "action_view",
                  // );
                  // intent.launch().then((value) {}).catchError((value) {
                  //   print('error camera ==> $value');
                  // });
                }),
          ],
        ),
      ),
    );
  }

  Future<void> checkLink() async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .collection('link')
        .where('urlLink', isEqualTo: newLink)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            backgroundColor: Colors.grey.shade900,
            title: const ShowText(label: 'Name Link'),
            content: ShowForm(
                label: 'Name Link',
                iconData: Icons.link,
                changeFunc: (String string) {
                  nameLink = string.trim();
                }),
            actions: [
              ShowIconButton(
                  iconData: Icons.send,
                  pressFunc: () {
                    if (nameLink?.isEmpty ?? true) {
                      Fluttertoast.showToast(
                        msg: 'Input Name Link',
                        toastLength: Toast.LENGTH_LONG,
                      );
                    } else {
                      processAddNameLink();
                    }
                  })
            ],
          ),
        );
      } else {
        Fluttertoast.showToast(msg: 'Have Link');
        addLinkController.text = '';
      }
    });
  }

  Future<void> processAddNameLink() async {
    LinkModel linkModel =
        LinkModel(nameLink: nameLink!, urlLink: newLink!, groupLink: '');

    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .collection('link')
        .doc()
        .set(linkModel.toMap())
        .then((value) {
      addLinkController.text = '';
      Fluttertoast.showToast(msg: 'Add Link Success');
      Navigator.pop(context);
    });
  }

  Widget newRowDown(BoxConstraints constraints, int index) {
    return ShowOutlineButton(
        label: postModels[index].nameButton,
        pressFunc: () {
          processClickButton(
              postModel: postModels[index],
              nameButton: postModels[index].nameButton);
        });
  }

  SizedBox newDiaplayImage(BoxConstraints constraints, int index) {
    return SizedBox(
      // width: constraints.maxWidth,
      height: constraints.maxHeight * 0.75,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: postModels[index].urlPaths.length,
        itemBuilder: (context, index2) => Stack(
          children: [
            SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Image.network(
                postModels[index].urlPaths[index2],
                fit: BoxFit.scaleDown,
              ),
            ),
            postModels[index].urlPaths.length == 1
                ? const SizedBox()
                : Positioned(
                    right: 0,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ShowText(
                          label:
                              '${index2 + 1}/${postModels[index].urlPaths.length}',
                          textStyle: MyConstant().h2Style(),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget newRowUp(BoxConstraints constraints, int index, BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: constraints.maxWidth * 0.5,
          child: InkWell(
            onTap: () {
              print('tap ==>>');
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 12,
                ),
                userModelPosts[index].avatar!.isEmpty
                    ? const ShowImage(
                        width: 36,
                      )
                    : ShowCircleImage(path: userModelPosts[index].avatar!),
                const SizedBox(
                  width: 12,
                ),
                SizedBox(
                  width: 120,
                  child: ShowText(
                    label: userModelPosts[index].name,
                    textStyle: MyConstant().h2WhiteStyle(),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: constraints.maxWidth * 0.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              (user!.uid == postModels[index].uidPost)
                  ? const SizedBox()
                  : ShowOutlineButton(
                      label: bolFollows[index] ? 'UnLink' : 'Link',
                      pressFunc: () async {
                        openProgress = true;
                        MyDialog(context: context).processDialog();

                        if (bolFollows[index]) {
                          print('Process unFollow');

                          await FirebaseFirestore.instance
                              .collection('user')
                              .doc(postModels[index].uidPost)
                              .collection('follow')
                              .doc(user!.uid)
                              .delete()
                              .then((value) {
                            // MyDialog(context: context).normalActionDilalog(
                            //     title: 'เลิกติดตามแล้ว',
                            //     message: 'เลิกติดตามเจ้าของโพสนี่แล้ว',
                            //     label: 'OK',
                            //     pressFunc: () {
                            //       Navigator.pop(context);
                            //     });
                            readPost();
                            setState(() {});
                          });
                        } else {
                          print('Click Follow');
                          print(
                              'uid ของเจ้าของโพส ---> ${postModels[index].uidPost}');
                          print('uid คนที่คลิก ติดตาม --->> ${user!.uid}');
                          print('token ==> $token');

                          FollowModel followModel = FollowModel(
                              uidClickFollow: user!.uid, token: token!);
                          await FirebaseFirestore.instance
                              .collection('user')
                              .doc(postModels[index].uidPost)
                              .collection('follow')
                              .doc(user!.uid)
                              .set(followModel.toMap())
                              .then((value) {
                            print('Success follow');
                            // MyDialog(context: context).normalActionDilalog(
                            //     title: 'ติดตามแล้ว',
                            //     message: 'ได้ติดตามเจ้าของโพสนี่แล้ว',
                            //     label: 'OK',
                            //     pressFunc: () {
                            //       Navigator.pop(context);
                            //     });
                            readPost();
                            setState(() {});
                          });
                        }
                      },
                    ),
              ShowIconButton(
                iconData: Icons.more_vert,
                pressFunc: () async {
                  print('Share Post');
                  await Share.share('https://play.google.com/store/apps/details?id=com.flutterthailand.admanyout # ${docIdPosts[index]}');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget newAvatarIcon() {
    return const ShowImage(
      width: 36,
    );
  }

  AppBar newAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: userModelLogin == null
          ? const SizedBox()
          : Row(
              children: [
                userModelLogin!.avatar!.isEmpty
                    ? InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ManageMyPost(),
                              )).then((value) {
                            print('##19may back from managepost');
                            readPost();
                          });
                        },
                        child: newAvatarIcon(),
                      )
                    : InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ManageMyPost(),
                              )).then((value) {
                            readPost();
                          });
                        },
                        child: ShowCircleImage(path: userModelLogin!.avatar!),
                      ),
                const SizedBox(
                  width: 16,
                ),
                DropdownButton<dynamic>(
                  underline: const SizedBox(),
                  value: title,
                  items: titles
                      .map(
                        (e) => DropdownMenuItem(
                          child: Text(e),
                          value: e,
                        ),
                      )
                      .toList(),
                  hint: ShowText(
                    label: MyConstant.appName,
                    textStyle: MyConstant().h2WhiteStyle(),
                  ),
                  onChanged: (value) {
                    if (value == titles[0]) {
                      print('Edit Profile');
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfile(),
                          )).then((value) {
                        readPost();
                      });
                    } else if (value == titles[1]) {
                      print('Process SignOut');
                      processSignOut();
                    }
                  },
                ),
              ],
            ),
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
      actions: [
        // ShowIconButton(
        //   iconData: Icons.search,
        //   pressFunc: () {},
        // ),
        // ShowIconButton(
        //   iconData: Icons.qr_code,
        //   pressFunc: () {},
        // ),
        ShowIconButton(
          iconData: Icons.add_box_outlined,
          pressFunc: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                // builder: (context) => const AddPhoto(),
                builder: (context) => const AddPhotoMulti(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget specialButton(BuildContext context) {
    return ShowButton(
        label: 'Special',
        pressFunc: () async {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          var result = preferences.getString('special');
          print('result ==> $result');
          if (result?.isEmpty ?? true) {
            MyDialog(context: context).normalActionDilalog(
                title: 'ต้องการ Key Special',
                message: 'คุณต้องกรองค่า key Special',
                label: 'กรอก key Spectial',
                pressFunc: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const KeySpecial(),
                      ));
                });
          } else {
            var specialModels = <SpecialModel>[];
            await FirebaseFirestore.instance
                .collection('user')
                .doc(user!.uid)
                .collection('special')
                .orderBy('expire', descending: true)
                .get()
                .then((value) {
              for (var item in value.docs) {
                SpecialModel specialModel = SpecialModel.fromMap(item.data());
                specialModels.add(specialModel);
              }
              if (result == specialModels[0].key) {
                print('สามารถใช้ Special');
              } else {
                MyDialog(context: context).normalActionDilalog(
                    title: 'key error',
                    message: 'ไม่สามารถใช้ special ได้',
                    label: 'OK',
                    pressFunc: () {
                      Navigator.pop(context);
                    });
                ;
              }
            });
          }
        });
  }

  Future<void> processSignOut() async {
    await FirebaseAuth.instance.signOut().then((value) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const Authen(),
          ),
          (route) => false);
    });
  }

  Future<void> processClickButton(
      {required PostModel2 postModel, required String nameButton}) async {
    var widgets = <Widget>[];

    var nameLinkShow = postModel.nameLinkShow;
    var link = postModel.link;
    var listWidgets = <List<Widget>>[];

    var listLink = <List<String>>[];

    for (var j = 0; j < nameLinkShow.length; j++) {
      var widgets = <Widget>[];
      var lisks = <String>[];

      for (var i = 0; i < nameLinkShow[j].length; i++) {
        String string = nameLinkShow[j]['name$i'];
        print('##10june string ==>> $string');

        String urlLink = link[j]['link$i'];
        print('##10june urlLink ==>> $urlLink');
        lisks.add(urlLink);

        widgets.add(
          InkWell(
            onTap: () async {
              print('##10june you click j ---> $j i ==> $i');
              print('##10june you click link ==> ${listLink[j][i]}');

              final Uri uri = Uri.parse(listLink[j][i]);
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                throw '##7may Cannot launch $uri';
              }
            },
            child: ShowText(label: string),
          ),
        );
      } // for2

      listLink.add(lisks);
      listWidgets.add(widgets);
    }

    int index = 0;
    for (var item in postModel.link) {
      widgets.add(
        ExpansionTile(
          title: ShowText(label: postModel.nameLink[index]),
          children: listWidgets[index],
        ),
      );
      index++;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: ListTile(
          // leading: const ShowImage(),
          title: ShowText(
            label: nameButton,
            textStyle: MyConstant().h2Style(),
          ),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: widgets,
        ),
      ),
    );
  }

  Future<void> processVotePost(
      {required String docIdPost, required bool score}) async {
    print('docIdPost ==>> $docIdPost, score ==> $score');
  }
}
