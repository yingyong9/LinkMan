// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:admanyout/states/list_all_my_link.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:admanyout/models/link_model.dart';
import 'package:admanyout/states/base_manage_my_link.dart';
import 'package:admanyout/widgets/show_form.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_text.dart';

class ControlAddLink extends StatefulWidget {
  final BoxConstraints constraints;
  final Function() successFunc;
  const ControlAddLink({
    Key? key,
    required this.constraints,
    required this.successFunc,
  }) : super(key: key);

  @override
  State<ControlAddLink> createState() => _ControlAddLinkState();
}

class _ControlAddLinkState extends State<ControlAddLink> {
  String? newLink, nameLink;
  var user = FirebaseAuth.instance.currentUser;
  TextEditingController addLinkController = TextEditingController();
  Function()? successFunc;

  @override
  void initState() {
    super.initState();
    successFunc = widget.successFunc;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: Container(
        width: widget.constraints.maxWidth,
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
                  print('Click Camera');
                  processSuccess();
                }),
          ],
        ),
      ),
    );
  }

  void processSuccess() {
    successFunc;
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
      //  Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => const ListAllMyLink(special: true,),
      //     ),
      //     (route) => false);
    });
  }
}
