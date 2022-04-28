// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:flutter/material.dart';

class MyDialog {
  final BuildContext context;
  MyDialog({
    required this.context,
  });

  Future<void> normalActionDilalog(
      {required String title,
      required String message,
      required String label,
      required Function() pressFunc}) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(backgroundColor: Colors.black.withOpacity(0.75),
        title: ListTile(
          leading: Icon(
            Icons.error,size: 48,
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
}
