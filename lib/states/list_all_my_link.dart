import 'package:admanyout/models/link_model.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_process.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_form.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:admanyout/widgets/show_text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ListAllMyLink extends StatefulWidget {
  const ListAllMyLink({Key? key}) : super(key: key);

  @override
  State<ListAllMyLink> createState() => _ListAllMyLinkState();
}

class _ListAllMyLinkState extends State<ListAllMyLink> {
  var user = FirebaseAuth.instance.currentUser;
  var linkModels = <LinkModel>[];
  var selectLinks = <bool>[];
  bool load = true;
  bool? haveLink;

  @override
  void initState() {
    super.initState();
    readAllLink();
  }

  Future<void> readAllLink() async {
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
              content: ShowForm(label: '', iconData: Icons.send, changeFunc: (String string){}),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          ShowIconButton(
              iconData: Icons.check_circle_outline,
              pressFunc: () {
                addNameGroupDialog();
              })
        ],
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: load
          ? const ShowProgress()
          : haveLink!
              ? ListView.builder(
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
                                      MyProcess().processLaunchUrl(
                                          url: linkModels[index].urlLink);
                                    })
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Center(
                  child: ShowText(
                  label: 'WithOut Link',
                  textStyle: MyConstant().h1Style(),
                )),
    );
  }
}
