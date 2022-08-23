// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/show_text.dart';

class ShowElevateButton extends StatelessWidget {
  final Function() pressFunc;
  final IconData iconData;
  final String label;
  final Color? colorIcon;
  final TextStyle? labelTextStyle;
  const ShowElevateButton({
    Key? key,
    required this.pressFunc,
    required this.iconData,
    required this.label,
    this.colorIcon,
    this.labelTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(primary: MyConstant.primary),
          onPressed: pressFunc,
          icon: Icon(
            iconData,
            color: colorIcon ?? Colors.white,
          ),
          label: ShowText(
            label: label,
            textStyle: labelTextStyle ?? MyStyle().h3Style(),
          )),
    );
  }
}
