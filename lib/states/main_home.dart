import 'package:admanyout/models/post_model.dart';
import 'package:admanyout/models/special_model.dart';
import 'package:admanyout/states/add_photo.dart';
import 'package:admanyout/states/authen.dart';
import 'package:admanyout/states/key_special.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_button.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_image.dart';
import 'package:admanyout/widgets/show_outline_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MainHome extends StatefulWidget {
  const MainHome({Key? key}) : super(key: key);

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  var user = FirebaseAuth.instance.currentUser;
  var postModels = <PostModel>[];
  var docIdPosts = <String>[];
  bool load = true;
  var titles = <String>['แก้ไขโปรไฟร์', 'Sign Out'];
  String? title;

  @override
  void initState() {
    super.initState();
    readPost();
  }

  Future<void> readPost() async {
    await FirebaseFirestore.instance
        .collection('post')
        .orderBy('timePost', descending: true)
        .get()
        .then((value) {
      for (var item in value.docs) {
        PostModel postModel = PostModel.fromMap(item.data());
        postModels.add(postModel);
        docIdPosts.add(item.id);
      }
      load = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: DropdownButton<dynamic>(
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
              if (value == titles[1]) {
                print('Process SignOut');
                processSignOut();
              }
            }),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        actions: [
          ShowIconButton(
            iconData: Icons.add_box_outlined,
            pressFunc: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddPhoto(),
              ),
            ),
          ),
        ],
      ),
      body: load
          ? const ShowProgress()
          : LayoutBuilder(builder: (context, constraints) {
              return ListView.builder(
                itemCount: postModels.length,
                itemBuilder: (context, index) => Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: constraints.maxWidth * 0.5,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 12,
                              ),
                              const ShowImage(
                                width: 36,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              SizedBox(
                                width: 120,
                                child: ShowText(
                                  label: postModels[index].name,
                                  textStyle: MyConstant().h2WhiteStyle(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: constraints.maxWidth * 0.5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ShowOutlineButton(
                                label: 'ติดตาม',
                                pressFunc: () {},
                              ),
                              ShowIconButton(
                                iconData: Icons.more_vert,
                                pressFunc: () {},
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxWidth * 0.75,
                      child: Image.network(
                        postModels[index].urlPaths[0],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.comment,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              width: constraints.maxWidth * 0.5 - 60,
                              child: ShowText(
                                label: postModels[index].article,
                                textStyle: MyConstant().h3WhiteStyle(),
                              ),
                            ),
                          ],
                        ),
                        // Badge(
                        //   badgeContent: ShowText(label: '0'),
                        //   child: ShowIconButton(
                        //     iconData: Icons.add_circle_outline,
                        //     pressFunc: () {
                        //       print('บวก docIdPost ==>> ${docIdPosts[index]}');
                        //       processVotePost(
                        //           docIdPost: docIdPosts[index], score: true);
                        //     },
                        //   ),
                        // ),
                        // Badge(
                        //   badgeContent: ShowText(label: '2'),
                        //   child: ShowIconButton(
                        //     iconData: Icons.remove_circle_outline,
                        //     pressFunc: () {
                        //       print('ลบ  docIdPost ==>> ${docIdPosts[index]}');
                        //       processVotePost(
                        //           docIdPost: docIdPosts[index], score: false);
                        //     },
                        //   ),
                        // ),
                        Column(
                          children: [
                            ShowOutlineButton(
                                label: postModels[index].nameButton,
                                pressFunc: () {
                                  processClickButton(
                                      postModel: postModels[index]);
                                }),
                            //  specialButton(context),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Divider(
                      color: Colors.grey,
                    ),
                  ],
                ),
              );
            }),
    );
  }

 Widget specialButton(BuildContext context)  {
    return ShowButton(
                              label: 'Special',
                              pressFunc: () async {
                                SharedPreferences preferences =
                                    await SharedPreferences.getInstance();
                                var result = preferences.getString('special');
                                print('result ==> $result');
                                if (result?.isEmpty ?? true) {
                                  MyDialog(context: context)
                                      .normalActionDilalog(
                                          title: 'ต้องการ Key Special',
                                          message:
                                              'คุณต้องกรองค่า key Special',
                                          label: 'กรอก key Spectial',
                                          pressFunc: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const KeySpecial(),
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
                                      SpecialModel specialModel =
                                          SpecialModel.fromMap(item.data());
                                      specialModels.add(specialModel);
                                    }
                                    if (result == specialModels[0].key) {
                                      print('สามารถใช้ Special');
                                    } else {
                                      MyDialog(context: context)
                                          .normalActionDilalog(
                                              title: 'key error',
                                              message:
                                                  'ไม่สามารถใช้ special ได้',
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

  Future<void> processClickButton({required PostModel postModel}) async {
    var widgets = <Widget>[];

    int index = 0;
    for (var item in postModel.link) {
      widgets.add(
        ShowButton(
          label: postModel.nameLink[index],
          pressFunc: () async {
            if (await canLaunch(item)) {
              await launch(item);
            } else {
              MyDialog(context: context).normalActionDilalog(
                  title: 'Cannot Launch',
                  message: 'Link False',
                  label: 'OK',
                  pressFunc: () => Navigator.pop(context));
            }
          },
        ),
      );
      index++;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.black,
        title: ListTile(
          leading: const ShowImage(),
          title: ShowText(
            label: 'Link',
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
