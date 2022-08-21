// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/widgets/show_text.dart';

class ShowFormLong extends StatelessWidget {
  final String label;
  final Function(String) changeFunc;
  final TextEditingController? textEditingController;
  final double? marginTop;
  const ShowFormLong({
    Key? key,
    required this.label,
    required this.changeFunc,
    this.textEditingController,
    this.marginTop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: marginTop ?? 16),
      child: TextFormField(
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
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
