// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/widgets/show_text.dart';

class ShowFormIconButton extends StatelessWidget {
  final double? width;
  final String? label;
  final IconData iconData;
  final Function(String) changeFunc;
  final bool? obscub;
  final TextInputType? textInputType;
  final TextEditingController? controller;
  final Function() pressFunc;
  const ShowFormIconButton({
    Key? key,
    this.width,
    this.label,
    required this.iconData,
    required this.changeFunc,
    this.obscub,
    this.textInputType,
    this.controller,
    required this.pressFunc,
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
        style: MyConstant().h2WhiteStyle(),
        obscureText: obscub ?? false,
        onChanged: changeFunc,
        decoration: InputDecoration(
          suffixIcon: IconButton(
              onPressed: pressFunc,
              icon: Icon(
                iconData,
                color: Colors.white,
              )),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          label: ShowText(label: label ?? ''),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyConstant.dark),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyConstant.light),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
