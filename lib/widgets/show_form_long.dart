// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:flutter/material.dart';

import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/widgets/show_text.dart';

class ShowFormLong extends StatelessWidget {
  final String label;
  final Function(String) changeFunc;
  final TextEditingController? textEditingController;
  final double? marginTop;
  final IconData? iconDataSubfix;
  final Function()? pressFunc;
  const ShowFormLong({
    Key? key,
    required this.label,
    required this.changeFunc,
    this.textEditingController,
    this.marginTop,
    this.iconDataSubfix,
    this.pressFunc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: marginTop ?? 16),
      child: TextFormField(
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          suffixIcon: iconDataSubfix == null
              ? const SizedBox()
              : ShowIconButton(
                  iconData: iconDataSubfix!,
                  pressFunc: pressFunc!,color: MyStyle.dark,
                ),
          label: ShowText(
            label: label,
            textStyle: MyConstant().h3BlackStyle(),
          ),
          enabledBorder: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(),
        ),
        controller: textEditingController,
        onChanged: changeFunc,
      ),
    );
  }
}
