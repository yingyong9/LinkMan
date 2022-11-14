// ignore_for_file: avoid_print

import 'package:admanyout/models/messaging_model.dart';
import 'package:admanyout/models/sos_post_model.dart';
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/states2/chat_room.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/utility/my_process.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:admanyout/widgets/widget_squire_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TotlalPartner extends StatefulWidget {
  const TotlalPartner({Key? key}) : super(key: key);

  @override
  State<TotlalPartner> createState() => _TotlalPartnerState();
}

class _TotlalPartnerState extends State<TotlalPartner> {
  var user = FirebaseAuth.instance.currentUser;
  var docIdMessagings = <String>[];
  var userModelPartners = <UserModel>[];
  var lastDetailModels = <SosPostModel>[];
  bool load = true;

  @override
  void initState() {
    super.initState();
    findPartnerFriend();
  }

  Future<void> findPartnerFriend() async {
    await FirebaseFirestore.instance
        .collection('messaging')
        .get()
        .then((value) async {
      // print('uidLogin ==> ${user!.uid}');
      for (var element in value.docs) {
        MessageingModel messageingModel =
            MessageingModel.fromMap(element.data());

        if (messageingModel.doubleMessages.contains(user!.uid)) {
          // print('messingModel ==> ${messageingModel.toMap()}');
          docIdMessagings.add(element.id);

          var uidPartners = messageingModel.doubleMessages;
          uidPartners.remove(user!.uid);
          // print('uidPartners ==> $uidPartners');
          String uidPartner = uidPartners[0];

          UserModel userModel =
              await MyFirebase().findUserModel(uid: uidPartner);
          userModelPartners.add(userModel);

          print('idDocMessage ==> ${element.id}');

          await FirebaseFirestore.instance
              .collection('messaging')
              .doc(element.id)
              .collection('detail')
              .orderBy('timePost')
              .get()
              .then((value) {
            if (value.docs.isEmpty) {
              SosPostModel model = SosPostModel(
                  post: '', uidPost: '', timePost: Timestamp.now());
              lastDetailModels.add(model);
            } else {
              SosPostModel? model;
              for (var element in value.docs) {
                model = SosPostModel.fromMap(element.data());
              }
              lastDetailModels.add(model!);
            }
          });
        }
      }
      load = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyStyle.dark,
      appBar: AppBar(
        backgroundColor: MyStyle.dark,
        foregroundColor: MyStyle.bgColor,
        title: ShowText(
          label: 'แชท',
          textStyle: MyStyle().h1Style(color: MyStyle.bgColor),
        ),
      ),
      body: load
          ? const ShowProgress()
          : ListView.builder(
              itemCount: userModelPartners.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    print('you tap docIdMessage ==> ${docIdMessagings[index]}');
                    Get.to(ChatRoom(docIdMessaging: docIdMessagings[index]));
                  },
                  leading: WidgetSquireAvatar(
                      urlImage: userModelPartners[index].avatar ??
                          MyConstant.urlLogo),
                  title: ShowText(
                    label: userModelPartners[index].name,
                    textStyle: MyStyle().h2Style(color: MyStyle.bgColor),
                  ),
                  subtitle: ShowText(
                    label: lastDetailModels[index].post,
                    textStyle: MyStyle().h3GreyStyle(),
                  ),
                  trailing: ShowText(
                    label: MyProcess().timeStampToString(timestamp: lastDetailModels[index].timePost),
                    textStyle: MyStyle().h3GreyStyle(),
                  ),
                );
              },
            ),
    );
  }
}
