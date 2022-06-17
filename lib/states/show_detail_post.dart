// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/widgets/show_image_avatar.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:flutter/material.dart';

import 'package:admanyout/models/post_model2.dart';

class ShowDetailPost extends StatefulWidget {
  final PostModel2 postModel2;
  const ShowDetailPost({
    Key? key,
    required this.postModel2,
  }) : super(key: key);

  @override
  State<ShowDetailPost> createState() => _ShowDetailPostState();
}

class _ShowDetailPostState extends State<ShowDetailPost> {
  PostModel2? postModel2;
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    postModel2 = widget.postModel2;
    findUserModel();
  }

  Future<void> findUserModel() async {
    await MyFirebase().findUserModel(uid: postModel2!.uidPost).then((value) {
      userModel = value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: ShowText(
          label: 'LinkMan# : ${postModel2!.shortcode}',
          textStyle: MyConstant().h2Style(),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: userModel == null
          ? const SizedBox()
          : LayoutBuilder(
            builder: (BuildContext context, BoxConstraints boxConstraints) {
              return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ShowImageAvatar(
                          urlImage: userModel!.avatar!,
                          size: 60,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        ShowText(
                          label: userModel!.name,
                          textStyle: MyConstant().h2Style(),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        SizedBox(
                          height: boxConstraints.maxHeight,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: postModel2!.urlPaths.length,
                            itemBuilder: (context, index) =>
                                Image.network(postModel2!.urlPaths[index]),
                          ),
                        )
                      ],
                    ),
                  ),
                );
            }
          ),
    );
  }
}
