// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/widgets/show_text.dart';

class ShowOutlineButton extends StatelessWidget {
  final String label;
  final Function() pressFunc;
  final double? width;
  const ShowOutlineButton({
    Key? key,
    required this.label,
    required this.pressFunc,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        onPressed: pressFunc,
        child: ShowText(
          label: label,
          textStyle: MyConstant().h3WhiteStyle(),
        ),
      ),
    );
  }
}
