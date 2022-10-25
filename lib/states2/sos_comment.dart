// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:admanyout/widgets/show_button.dart';
import 'package:admanyout/widgets/show_form_long.dart';

class SosComment extends StatefulWidget {
  final String docIdSos;
  const SosComment({
    Key? key,
    required this.docIdSos,
  }) : super(key: key);

  @override
  State<SosComment> createState() => _SosCommentState();
}

class _SosCommentState extends State<SosComment> {
  String? post, docIdSos;
  var user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    docIdSos = widget.docIdSos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: LayoutBuilder(builder: (context, BoxConstraints boxConstraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).requestFocus(FocusScopeNode()),
          child: SizedBox(
            width: boxConstraints.maxWidth,
            height: boxConstraints.maxHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                newPost(boxConstraints: boxConstraints),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget newPost({required BoxConstraints boxConstraints}) {
    return Positioned(
      bottom: 8,
      child: SizedBox(
        width: boxConstraints.maxWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 250,
              child: ShowFormLong(
                label: 'Post',
                changeFunc: (p0) {
                  post = p0.trim();
                },
              ),
            ),
            ShowButton(
              label: 'Post',
              pressFunc: () {
                if (!(post?.isEmpty ?? true)) {
                  DateTime dateTime = DateTime.now();
                  print(
                      'post ==> $post, uid ==> ${user!.uid}, dateTime ==> $dateTime, docIdSos ==> $docIdSos');
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
