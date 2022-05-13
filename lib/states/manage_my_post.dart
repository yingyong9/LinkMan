import 'package:admanyout/models/post_model.dart';
import 'package:admanyout/utility/my_constant.dart';
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

  @override
  void initState() {
    super.initState();
    readMyAllPost();
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
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: load
          ? const ShowProgress()
          : haveData!
              ? GridView.builder(
                  itemCount: postModels.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemBuilder: (BuildContext context, int index) =>
                      ShowText(label: postModels[index].name))
              : Center(
                  child: ShowText(
                  label: 'No Post',
                  textStyle: MyConstant().h1Style(),
                )),
    );
  }
}
