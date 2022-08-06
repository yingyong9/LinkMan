// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:flutter/material.dart';

class ShowFormLong extends StatelessWidget {
  final String label;
  final Function(String) changeFunc;
  final TextEditingController? textEditingController;
  const ShowFormLong({
    Key? key,
    required this.label,
    required this.changeFunc,
    this.textEditingController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        label: ShowText(
          label: label,
          textStyle: MyConstant().h3BlackStyle(),
        ),
        enabledBorder: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
      ),
      controller: textEditingController,
      onChanged: changeFunc,
    );
  }
}
