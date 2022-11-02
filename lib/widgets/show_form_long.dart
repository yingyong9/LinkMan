// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_text.dart';

class ShowFormLong extends StatelessWidget {
  final String label;
  final Function(String) changeFunc;
  final TextEditingController? textEditingController;
  final double? marginTop;
  final IconData? iconDataSubfix;
  final Function()? pressFunc;
  final Color? color;
  final Color? fixColor;

  const ShowFormLong({
    Key? key,
    required this.label,
    required this.changeFunc,
    this.textEditingController,
    this.marginTop,
    this.iconDataSubfix,
    this.pressFunc,
    this.color,
    this.fixColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: marginTop ?? 16),
      child: TextFormField(
        style: color == null ? MyStyle().h3Style() : MyStyle().h3WhiteStyle(),
        minLines: 1,
        maxLines: 4,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          filled: true,
          fillColor: fixColor,
          suffixIcon: iconDataSubfix == null
              ? const SizedBox()
              : ShowIconButton(
                  iconData: iconDataSubfix!,
                  pressFunc: pressFunc!,
                  color: MyStyle.dark,
                ),
          label: ShowText(
            label: label,
            textStyle: color == null
                ? MyConstant().h3BlackStyle()
                : MyStyle().h3WhiteStyle(),
          ),
          // enabledBorder: OutlineInputBorder(
          //     borderSide: BorderSide(color: color ?? MyStyle.dark)),
          // focusedBorder: OutlineInputBorder(
          //     borderSide: BorderSide(color: color ?? MyStyle.dark)),
        ),
        controller: textEditingController,
        onChanged: changeFunc,
      ),
    );
  }
}
