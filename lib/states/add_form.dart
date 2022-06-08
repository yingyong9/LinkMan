// ignore_for_file: public_member_api_docs, sort_constructors_first, prefer_const_constructors, avoid_print
import 'package:admanyout/models/follow_model.dart';
import 'package:admanyout/models/link_model.dart';
import 'package:admanyout/models/post_model.dart';
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/states/list_all_my_link.dart';
import 'package:admanyout/states/main_home.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/widgets/show_button.dart';
import 'package:admanyout/widgets/show_form.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_outline_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:admanyout/models/photo_model.dart';

class AddForm extends StatefulWidget {
  final List<PhotoModel> photoModels;
  const AddForm({
    Key? key,
    required this.photoModels,
  }) : super(key: key);

  @override
  State<AddForm> createState() => _AddFormState();
}

class _AddFormState extends State<AddForm> {
  var photoModels = <PhotoModel>[];
  var widgetLinks = <Widget>[];
  var links = <String>[];
  var urlPath = <String>[];

  var nameLinks = <String>[];

  int indexTextFromField = 0;
  String article = '', nameButton = 'กดปุ่ม';
  String? uidPost, name;
  var user = FirebaseAuth.instance.currentUser;

  var linkModels = <LinkModel>[];
  bool load = true;
  bool? haveLink;

  var nameGroups = <String>[];

  @override
  void initState() {
    super.initState();
    photoModels = widget.photoModels;
    widgetLinks.add(createTextFromFiew(indexTextFromField));

    for (var item in photoModels) {
      urlPath.add(item.urlPhoto);
    }

    findUserLogin();
    findMyAllLink();
  }

  Future<void> findMyAllLink() async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .collection('link')
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        //Without Link
        haveLink = false;
      } else {
        for (var element in value.docs) {
          LinkModel linkModel = LinkModel.fromMap(element.data());
          linkModels.add(linkModel);
        }

        load = false;
        haveLink = true;
        setState(() {});
      }
    });
  }

  Future<void> findUserLogin() async {
    uidPost = user!.uid;

    await FirebaseFirestore.instance
        .collection('user')
        .doc(uidPost)
        .get()
        .then((value) {
      UserModel userModel = UserModel.fromMap(value.data()!);
      name = userModel.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: newAppBar(context),
      body: LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusScopeNode()),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            child: Column(
              children: [
                showListImage(constraints),
                // newAddMoreLink(),
                // buttonLinkUrl(),
                nameGroups.isEmpty
                    ? const SizedBox()
                    : ListView.builder(shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: nameGroups.length,
                        itemBuilder: (context, index) =>
                            ShowText(label: nameGroups[index]),
                      ),
                ShowOutlineButton(
                    label: 'Choose Link',
                    pressFunc: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ListAllMyLink();
                          },
                        ),
                      ).then((value) {
                        if (value != null) {
                          var result = value;
                          String nameGroup = result['nameGroup'];
                          var linkModels = result['choosed'];
                          nameGroups.add(nameGroup);
                          setState(() {});
                        }
                      });
                    }),
                formNameButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ShowForm formNameButton() {
    return ShowForm(
      label: 'ชื่อปุ่ม',
      iconData: Icons.bookmark,
      changeFunc: (String string) {
        nameButton = string.trim();
      },
    );
  }

  Row buttonLinkUrl() {
    return Row(
      children: [
        ShowButton(
            label: 'Link URL +',
            pressFunc: () {
              indexTextFromField++;
              setState(() {
                widgetLinks.add(createTextFromFiew(indexTextFromField));
              });
            }),
      ],
    );
  }

  Column newAddMoreLink() {
    return Column(
      children: widgetLinks,
    );
  }

  AppBar newAppBar(BuildContext context) {
    return AppBar(
      actions: [
        ShowIconButton(
            iconData: Icons.check,
            pressFunc: () async {
              // print(
              //     'uidPost ==> $uidPost, artical ==> $article, nameButton = => $nameButton');
              // print('links ===>> $links');
              // print('urlPath ==> $urlPath');

              DateTime dateTime = DateTime.now();
              Timestamp timePost = Timestamp.fromDate(dateTime);

              PostModel postModel = PostModel(
                uidPost: uidPost!,
                urlPaths: urlPath,
                article: article,
                link: links,
                nameButton: nameButton,
                name: name!,
                timePost: timePost,
                nameLink: nameLinks,
              );

              print('postModel ==>> ${postModel.toMap()}');

              await FirebaseFirestore.instance
                  .collection('post')
                  .doc()
                  .set(postModel.toMap())
                  .then((value) async {
                await FirebaseFirestore.instance
                    .collection('user')
                    .doc(uidPost)
                    .collection('follow')
                    .get()
                    .then((value) {
                  print('##30April value aaaa ==> ${value.docs}');

                  if (value.docs.isEmpty) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainHome(),
                        ),
                        (route) => false);
                  } else {
                    for (var item in value.docs) {
                      FollowModel followModel =
                          FollowModel.fromMap(item.data());
                      print(
                          '##30April followModel ==>> ${followModel.toMap()}');

                      processSentNoti(tokenFollow: followModel.token);
                    }
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainHome(),
                        ),
                        (route) => false);
                  }
                });
              });
            })
      ],
      leading: ShowIconButton(
          iconData: Icons.arrow_back,
          pressFunc: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const MainHome(),
              ),
              (route) => false)),
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
    );
  }

  Widget createTextFromFiew(int index) {
    links.add('');
    nameLinks.add('');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // link
        SizedBox(
          width: 120,
          child: TextFormField(
            style: MyConstant().h3WhiteStyle(),
            onChanged: (value) {
              try {
                int testNum = int.parse(value);
                print('นี่คือ ตัวเลข');
                links[index] = 'tel:${value.trim()}';
              } catch (e) {
                print('นี่ีืคือ ตัวอักษร');
                String string = value.trim();
                string = string.substring(0, 8);
                print('##7may string ==> $string');
                if (string == 'https://') {
                  links[index] = value.trim();
                } else {
                  links[index] = 'https://${value.trim()}';
                }
              }

              // links[index] = value.trim();
            },
            decoration: InputDecoration(
              hintStyle: MyConstant().h2WhiteStyle(),
              hintText: 'Link url',
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
            ),
          ),
        ),
        // name
        SizedBox(
          width: 120,
          child: TextFormField(
            style: MyConstant().h3WhiteStyle(),
            onChanged: (value) {
              nameLinks[index] = value.trim();
            },
            decoration: InputDecoration(
              hintStyle: MyConstant().h2WhiteStyle(),
              hintText: 'Name Link',
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  Widget showListImage(BoxConstraints constraints) => SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: photoModels.length,
          itemBuilder: (context, index) => SizedBox(
            width: constraints.maxWidth,
            child: Image.network(
              photoModels[index].urlPhoto,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );

  Row addDescriptionImage(BoxConstraints constraints) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          width: constraints.maxWidth * 0.8,
          child: Image.network(photoModels[0].urlPhoto),
        ),
        SizedBox(
          width: constraints.maxWidth * 0.5,
          child: TextFormField(
            onChanged: (value) {
              article = value.trim();
            },
            maxLines: 10,
            keyboardType: TextInputType.multiline,
            style: MyConstant().h3WhiteStyle(),
            decoration: InputDecoration(
              hintText: 'เขียนคำบรรยาย ...',
              hintStyle: MyConstant().h3WhiteStyle(),
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

  Future<void> processSentNoti({required String tokenFollow}) async {
    print('##30April tokenFollow ==>> $tokenFollow');
  }
}
