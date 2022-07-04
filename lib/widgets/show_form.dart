// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_text.dart';

class ShowForm extends StatelessWidget {
  final double? width;
  final String label;
  final IconData iconData;
  final Function(String) changeFunc;
  final bool? obscub;
  final TextInputType? textInputType;
  final TextEditingController? controller;
  final Function()? pressFunc;
  final Color? colorTheme;
  const ShowForm({
    Key? key,
    this.width,
    required this.label,
    required this.iconData,
    required this.changeFunc,
    this.obscub,
    this.textInputType,
    this.controller,
    this.pressFunc,
    this.colorTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      width: width ?? 250,
      height: 40,
      child: TextFormField(
        controller: controller,
        keyboardType: textInputType ?? TextInputType.text,
        style: colorTheme == null
            ? MyConstant().h2WhiteStyle()
            : MyConstant().h3BlackStyle(),
        obscureText: obscub ?? false,
        onChanged: changeFunc,
        decoration: InputDecoration(filled: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          suffixIcon: ShowIconButton(color: colorTheme ?? Colors.white,
            iconData: iconData,
            pressFunc: pressFunc ?? () {},
          ),
          label: ShowText(
            label: label,
            textStyle: colorTheme == null
                ? MyConstant().h3Style()
                : MyConstant().h3BlackStyle(),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorTheme ?? MyConstant.dark),
            borderRadius: colorTheme == null
                ? BorderRadius.circular(30)
                : BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyConstant.light),
            borderRadius: colorTheme == null
                ? BorderRadius.circular(30)
                : BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
