// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:admanyout/utility/my_constant.dart';
import 'package:flutter/material.dart';

import 'package:admanyout/widgets/show_text.dart';

class ShowTextButton extends StatelessWidget {
  final String label;
  final Function() pressFunc;
  const ShowTextButton({
    Key? key,
    required this.label,
    required this.pressFunc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: pressFunc,
      child: ShowText(label: label, textStyle: MyConstant().h3ActionStyle(),),
    );
  }
}
