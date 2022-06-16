// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/utility/my_constant.dart';
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
  }

  void findUserModel() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: ShowText(
          label: 'CodeLink : ${postModel2!.shortcode}',
          textStyle: MyConstant().h2Style(),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
    );
  }
}
