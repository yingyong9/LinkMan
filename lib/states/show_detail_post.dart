// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/states/list_link.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/widgets/show_image_avatar.dart';
import 'package:admanyout/widgets/show_outline_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:flutter/material.dart';

import 'package:admanyout/models/post_model2.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

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
  var widgets = <Widget>[];

  @override
  void initState() {
    super.initState();
    postModel2 = widget.postModel2;
    createWidgets();
    findUserModel();
  }

  void createWidgets() {
    for (var element in postModel2!.urlPaths) {
      widgets.add(Image.network(element));
    }
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
                      ImageSlideshow(
                        children: widgets,
                        width: boxConstraints.maxWidth,
                        height: 450,
                        initialPage: 0,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        width: boxConstraints.maxWidth,
                        child: ShowOutlineButton(
                          label: '${postModel2!.nameButton} >',
                          pressFunc: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ListLink(postModel2: postModel2!),
                                ));
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
              );
            }),
    );
  }

  SizedBox listViewHorizantal(BoxConstraints boxConstraints) {
    return SizedBox(
      height: boxConstraints.maxHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: postModel2!.urlPaths.length,
        itemBuilder: (context, index) =>
            Image.network(postModel2!.urlPaths[index]),
      ),
    );
  }
}
