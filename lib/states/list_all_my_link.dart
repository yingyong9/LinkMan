// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:admanyout/states/add_form.dart';
import 'package:admanyout/states/base_manage_my_link.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:admanyout/models/link_model.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_process.dart';
import 'package:admanyout/widgets/control_add_link.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_form_icon_button.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:admanyout/widgets/show_text_button.dart';

class ListAllMyLink extends StatefulWidget {
  final bool? special;
  const ListAllMyLink({
    Key? key,
    this.special,
  }) : super(key: key);

  @override
  State<ListAllMyLink> createState() => _ListAllMyLinkState();
}

class _ListAllMyLinkState extends State<ListAllMyLink> {
  var user = FirebaseAuth.instance.currentUser;
  var linkModels = <LinkModel>[];
  var selectLinks = <bool>[];
  bool load = true;
  bool? haveLink;
  bool statusChooseOneLink = false;

  TextEditingController controller = TextEditingController();

  String? nameGroup;
  bool special = false;

  @override
  void initState() {
    super.initState();
    if (widget.special != null) {
      special = true;
    }
    readAllLink();
  }

  Future<void> readAllLink() async {
    if (linkModels.isNotEmpty) {
      linkModels.clear();
      selectLinks.clear();
    }

    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .collection('link')
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        haveLink = false;
      } else {
        haveLink = true;
        for (var element in value.docs) {
          LinkModel linkModel = LinkModel.fromMap(element.data());
          linkModels.add(linkModel);
          selectLinks.add(false);
        }
      }

      load = false;
      setState(() {});
    });
  }

  void checkChooseOneLink() {
    for (var element in selectLinks) {
      if (element) {
        statusChooseOneLink = true;
      }
    }
  }

  Future<void> addNameGroupDialog() async {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              backgroundColor: Colors.grey.shade900,
              title: ListTile(
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 36,
                ),
                title: ShowText(
                  label: 'Input Name',
                  textStyle: MyConstant().h2Style(),
                ),
              ),
              content: ShowFormIconButton(
                iconData: Icons.link,
                changeFunc: (String string) {
                  nameGroup = string.trim();
                },
                pressFunc: () {
                  print('You Click');
                  if (nameGroup?.isEmpty ?? true) {
                    Fluttertoast.showToast(
                        msg: 'Please Fill Name Link', textColor: Colors.red);
                  } else {
                    processTakeData();
                  }
                },
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          ShowIconButton(
              iconData: Icons.link,
              pressFunc: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BaseManageMyLink(),
                    )).then((value) {
                  readAllLink();
                });
              }),
          ShowIconButton(
              iconData: Icons.check_circle_outline,
              pressFunc: () {
                checkChooseOneLink();
                if (statusChooseOneLink) {
                  addNameGroupDialog();
                } else {
                  Fluttertoast.showToast(
                      msg: 'Please Choose Link', textColor: Colors.red);
                }
              })
        ],
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: load
          ? const ShowProgress()
          : haveLink!
              ? LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                  return listviewLink();
                })
              : Center(
                  child: ShowText(
                  label: 'WithOut Link',
                  textStyle: MyConstant().h1Style(),
                )),
    );
  }

  ListView listviewLink() {
    return ListView.builder(
      itemCount: linkModels.length,
      itemBuilder: (context, index) => Card(
        color: Colors.grey.shade900,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Theme(
                    data: Theme.of(context).copyWith(
                      unselectedWidgetColor: Colors.white,
                    ),
                    child: Checkbox(
                      value: selectLinks[index],
                      onChanged: (value) {
                        setState(() {
                          selectLinks[index] = value!;
                        });
                      },
                    )),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShowText(
                      label: linkModels[index].nameLink,
                      textStyle: MyConstant().h2Style(),
                    ),
                    ShowTextButton(
                        label: linkModels[index].urlLink,
                        pressFunc: () {
                          MyProcess()
                              .processLaunchUrl(url: linkModels[index].urlLink);
                        })
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void processTakeData() {
    var choosedLinkModels = <LinkModel>[];

    for (var i = 0; i < selectLinks.length; i++) {
      if (selectLinks[i]) {
        choosedLinkModels.add(linkModels[i]);
      }
    }

    print('name ==> $nameGroup, ${choosedLinkModels.length}');
    Map<String, dynamic> map = {};
    map['nameGroup'] = nameGroup;

    map['choosed'] = choosedLinkModels;
    print('map ====>> $map');
    Navigator.pop(context);
    Navigator.pop(context, map);
  }
}
