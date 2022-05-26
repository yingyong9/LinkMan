// ignore_for_file: avoid_print

import 'package:admanyout/models/link_model.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_form.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_outline_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageMyLink extends StatefulWidget {
  const ManageMyLink({Key? key}) : super(key: key);

  @override
  State<ManageMyLink> createState() => _ManageMyLinkState();
}

class _ManageMyLinkState extends State<ManageMyLink> {
  var user = FirebaseAuth.instance.currentUser;
  var linkModels = <LinkModel>[];
  bool load = true;
  bool? haveData;

  String? newLink;

  String? nameLink;

  TextEditingController addLinkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    readMyLink();
  }

  Future<void> readMyLink() async {
    if (linkModels.isNotEmpty) {
      linkModels.clear();
    }
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .collection('link')
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        haveData = false;
      } else {
        haveData = true;

        for (var element in value.docs) {
          LinkModel linkModel = LinkModel.fromMap(element.data());
          linkModels.add(linkModel);
        }
      }

      load = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   actions: [
      //     Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         Container(margin: const EdgeInsets.only(right: 16),
      //           height: 40,
      //           child: ShowOutlineButton(
      //             label: 'Choice',
      //             pressFunc: () {},
      //           ),
      //         ),
      //       ],
      //     ),
      //   ],
      //   backgroundColor: Colors.black,
      //   foregroundColor: Colors.white,
      // ),
      body: load
          ? const ShowProgress()
          : haveData!
              ? LayoutBuilder(builder: (context, constraints) {
                  return Stack(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemCount: linkModels.length,
                        itemBuilder: (context, index) => Card(
                          color: Colors.grey.shade900,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: ShowText(
                                        label: linkModels[index].nameLink)),
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () {
                                      print('You tab url ==>> $index');
                                      processLanchUrl(
                                          url: linkModels[index].urlLink);
                                    },
                                    child: ShowText(
                                      label: linkModels[index].urlLink,
                                      textStyle: MyConstant().h3ActionStyle(),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      controlAddLink(constraints),
                    ],
                  );
                })
              : Center(
                  child: ShowText(
                  label: 'No Link',
                  textStyle: MyConstant().h1Style(),
                )),
    );
  } // build

  Future<void> processLanchUrl({required String url}) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'cannot launch $url';
    }
  }

  Widget controlAddLink(BoxConstraints constraints) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: constraints.maxWidth,
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShowForm(
                controller: addLinkController,
                label: 'Add Link',
                iconData: Icons.link,
                changeFunc: (String string) {
                  newLink = string.trim();
                },
              ),
              newLink?.isEmpty ?? true
                  ? const SizedBox()
                  : ShowIconButton(
                      iconData: Icons.send,
                      pressFunc: () async {
                        checkLink();
                      },
                    ),
            ],
          ),
        ),
      ],
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
                  },),
                  ShowIconButton(iconData: Icons.public, pressFunc: (){},),
                  ShowIconButton(iconData: Icons.two_k, pressFunc: (){},),
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
      readMyLink();
    });
  }
}
