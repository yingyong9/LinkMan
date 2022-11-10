// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/show_text.dart';

class ShowButton extends StatelessWidget {
  final String label;
  final Function() pressFunc;
  final double? opacity;
  final Color? bgColor;
  final TextStyle? labelStyle;
  final double? width;
  const ShowButton({
    Key? key,
    required this.label,
    required this.pressFunc,
    this.opacity,
    this.bgColor,
    this.labelStyle,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(width: width,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              bgColor ?? MyConstant.primary.withOpacity(opacity ?? 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: pressFunc,
        child: ShowText(
          label: label,
          textStyle: labelStyle ?? MyStyle().h2Style(),
        ),
      ),
    );
  }
}
