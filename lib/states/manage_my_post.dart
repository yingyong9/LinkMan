// ignore_for_file: avoid_print

import 'package:admanyout/models/post_model.dart';
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/states/edit_post.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_outline_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManageMyPost extends StatefulWidget {
  const ManageMyPost({Key? key}) : super(key: key);

  @override
  State<ManageMyPost> createState() => _ManageMyPostState();
}

class _ManageMyPostState extends State<ManageMyPost> {
  var user = FirebaseAuth.instance.currentUser;
  var postModels = <PostModel>[];
  var docIdPosts = <String>[];
  var selects = <bool>[];
  bool load = true;
  bool? haveData;
  bool displaySelect = false; // false ==> disible CheckBox
  bool displayDeleteIcon = false; // false ==> disible IconDelete

  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    readMyAllPost();
    findUserModel();
  }

  Future<void> findUserModel() async {
    await MyFirebase().findUserModel(uid: user!.uid).then((value) {
      userModel = value;
      setState(() {});
    });
  }

  Future<void> readMyAllPost() async {
    if (postModels.isNotEmpty) {
      postModels.clear();
      docIdPosts.clear();
      selects.clear();
      displaySelect = false;
      displayDeleteIcon = false;
    }

    await FirebaseFirestore.instance
        .collection('post')
        .where('uidPost', isEqualTo: user!.uid)
        .get()
        .then((value) {
      print('##8may value ==>> ${value.docs}');
      load = false;

      if (value.docs.isEmpty) {
        haveData = false;
      } else {
        for (var element in value.docs) {
          PostModel postModel = PostModel.fromMap(element.data());
          postModels.add(postModel);
          docIdPosts.add(element.id);
          selects.add(false);
        }

        haveData = true;
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: ShowText(
          label: userModel == null ? '' : userModel!.name,
          textStyle: MyConstant().h2Style(),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        actions: [
          displayDeleteIcon
              ? ShowIconButton(
                  iconData: Icons.delete_forever_outlined,
                  pressFunc: () async {
                    for (var i = 0; i < selects.length; i++) {
                      if (selects[i]) {
                        print('##19may ===>> ${docIdPosts[i]}');

                        await FirebaseFirestore.instance
                            .collection('post')
                            .doc(docIdPosts[i])
                            .delete();
                      }
                    }

                    readMyAllPost();

                    setState(() {});
                  })
              : const SizedBox(),
          load
              ? const SizedBox()
              : haveData!
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 40,
                          child: ShowOutlineButton(
                              label: displaySelect ? 'UnSelect' : 'Select',
                              pressFunc: () {
                                for (var i = 0; i < selects.length; i++) {
                                  selects[i] = false;
                                }
                                displaySelect = !displaySelect;
                                setState(() {});
                              }),
                        ),
                      ],
                    )
                  : const SizedBox(),
        ],
      ),
      body: load
          ? const ShowProgress()
          : haveData!
              ? GridView.builder(
                  itemCount: postModels.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 1,
                      // mainAxisSpacing: 8,
                      // crossAxisSpacing: 8,
                      crossAxisCount: 3),
                  itemBuilder: (BuildContext context, int index) => SizedBox(
                    // width: 100,
                    // height: 180,
                    child: InkWell(
                      onTap: () {
                        print('You Click ==> ${postModels[index].name}');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPost(
                                postModel: postModels[index],
                                docIdPost: docIdPosts[index],
                              ),
                            )).then((value) {
                          readMyAllPost();
                        });
                      },
                      child: Stack(
                        children: [
                          Image.network(
                            postModels[index].urlPaths[0],
                            fit: BoxFit.fill,
                          ),
                          displaySelect
                              ? Positioned(
                                  child: Theme(
                                      data: Theme.of(context).copyWith(
                                          unselectedWidgetColor: Colors.white),
                                      child: Checkbox(
                                        value: selects[index],
                                        onChanged: (value) {
                                          selects[index] = value!;

                                          displayDeleteIcon = false;
                                          for (var i = 0;
                                              i < selects.length;
                                              i++) {
                                            if (selects[i]) {
                                              displayDeleteIcon = true;
                                            }
                                          }

                                          setState(() {});
                                        },
                                      )),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                )
              : Center(
                  child: ShowText(
                  label: 'No Post',
                  textStyle: MyConstant().h1Style(),
                )),
    );
  }
}
