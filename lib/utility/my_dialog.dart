// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:flutter/material.dart';

class MyDialog {
  final BuildContext context;
  MyDialog({
    required this.context,
  });

  

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
        backgroundColor: Colors.black.withOpacity(0.75),
        title: ListTile(
          leading: Icon(
            Icons.error,
            size: 48,
            color: MyConstant.primary,
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
