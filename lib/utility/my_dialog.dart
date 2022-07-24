// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:admanyout/states/base_manage_my_link.dart';
import 'package:admanyout/states/edit_profile.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_image.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:flutter/material.dart';

class MyDialog {
  final BuildContext context;
  MyDialog({
    required this.context,
  });

  Future<void> buttonSheetDialog() async {
    var iconDatas = <IconData>[
      Icons.link_outlined,
      Icons.group,
      Icons.videocam,
      Icons.inventory_2,
      Icons.manage_accounts,
      Icons.logout_outlined
    ];

    var titles = <String>[
      'Follow',
      '@Group',
      'Live',
      'Stock Link',
      'Profile',
      'Sign Out',
    ];

    var tapFuncs = <Function()>[
      () {
         Navigator.pop(context);
      },
      () {
         Navigator.pop(context);
      },
      () {
         Navigator.pop(context);
      },
      () {
        print('Click StockLink');
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BaseManageMyLink(),
            )).then((value) {
          print('pop from BaseMenageLink');
        });
      },
      () {
        print('Click Prifile');
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditProfile(),
            ));
      },
      () {
        print('Click SignOut');
        Navigator.pop(context);
        MyFirebase().processSignOut(context: context);
      },
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) =>
          LayoutBuilder(builder: (context, BoxConstraints boxConstraints) {
        return Container(
          decoration: const BoxDecoration(color: Colors.black),
          height: boxConstraints.maxWidth * 0.6 + 16,
          child: GridView.builder(
            itemCount: titles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            itemBuilder: (context, index) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: tapFuncs[index],
                  child: SizedBox(
                    width: boxConstraints.maxWidth * 0.3,
                    height: boxConstraints.maxWidth * 0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: Card(
                            color: const Color.fromARGB(255, 51, 49, 49),
                            child: Icon(
                              iconDatas[index],
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                        ShowText(
                          label: titles[index],
                          textStyle: MyConstant().h3WhiteStyle(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> processDialog() async {
    showDialog(
        context: context,
        builder: (BuildContext context) => WillPopScope(
            child: const ShowProgress(),
            onWillPop: () async {
              return false;
            }));
  }

  Future<void> normalActionDilalog(
      {required String title,
      required String message,
      required String label,
      required Function() pressFunc}) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: ListTile(
          leading: const ShowImage(
            path: 'images/logo.png',
            width: 80,
          ),
          title: ShowText(
            label: title,
            textStyle: MyConstant().h2Style(),
          ),
          subtitle: ShowText(label: message),
        ),
        actions: [
          TextButton(onPressed: pressFunc, child: ShowText(label: label))
        ],
      ),
    );
  }

  Future<void> twoActionDilalog({
    required String title,
    required String message,
    required String label1,
    required String label2,
    required Function() pressFunc1,
    required Function() pressFunc2,
    Widget? contentWidget,
  }) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 77, 74, 74).withOpacity(0.75),
        title: ListTile(
          // leading: Icon(
          //   Icons.error,
          //   size: 48,
          //   color: MyConstant.primary,
          // ),
          title: ShowText(
            label: title,
            textStyle: MyConstant().h2Style(),
          ),
          subtitle: ShowText(label: message),
        ),
        content: contentWidget ?? const SizedBox(),
        actions: [
          TextButton(onPressed: pressFunc1, child: ShowText(label: label1)),
          TextButton(onPressed: pressFunc2, child: ShowText(label: label2)),
        ],
      ),
    );
  }
}
