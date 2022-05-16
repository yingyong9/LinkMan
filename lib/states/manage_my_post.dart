// ignore_for_file: avoid_print

import 'package:admanyout/models/post_model.dart';
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/states/edit_post.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/widgets/shop_progress.dart';
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
  bool load = true;
  bool? haveData;
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
      ),
      body: load
          ? const ShowProgress()
          : haveData!
              ? GridView.builder(
                  itemCount: postModels.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      // childAspectRatio: 1,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      crossAxisCount: 3),
                  itemBuilder: (BuildContext context, int index) => SizedBox(
                    width: 100,
                    height: 180,
                    child: InkWell(
                      onTap: () {
                        print('You Click ==> ${postModels[index].name}');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditPost(postModel: postModels[index]),
                            ));
                      },
                      child: Image.network(
                        postModels[index].urlPaths[0],
                        fit: BoxFit.cover,
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
