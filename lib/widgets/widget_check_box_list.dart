// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/show_text.dart';

class WidgetCheckBoxLis extends StatelessWidget {
  final bool status;
  final String title;
  final Function(bool?) statusFunc;
  const WidgetCheckBoxLis({
    Key? key,
    required this.status,
    required this.title,
    required this.statusFunc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(unselectedWidgetColor: Colors.white),
      child: CheckboxListTile(
        contentPadding: EdgeInsets.all(2),
        controlAffinity: ListTileControlAffinity.leading,
        value: status,
        onChanged: statusFunc,
        title: ShowText(
          label: title,
          textStyle: MyStyle().h3WhiteStyle(),
        ),
      ),
    );
  }
}
