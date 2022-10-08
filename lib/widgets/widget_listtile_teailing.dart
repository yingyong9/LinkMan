// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:flutter/material.dart';

class WidgetListtileTeailing extends StatelessWidget {
  final IconData leadIcon;
  final IconData? telingIcon;
  final String title;
  final Color? contentColor;
  final Function() pressFunc;
  const WidgetListtileTeailing({
    Key? key,
    required this.leadIcon,
    this.telingIcon,
    required this.title,
    this.contentColor,
    required this.pressFunc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -4),
      leading: Icon(
        leadIcon,
        color: contentColor ?? MyStyle.dark,
      ),
      title: ShowText(
        label: title,
        textStyle: MyStyle().h2Style(color: contentColor ?? MyStyle.dark),
      ),
      trailing: telingIcon == null
          ? const SizedBox()
          : Icon(
              telingIcon,
              color: contentColor ?? MyStyle.dark,
            ),
            onTap: pressFunc,
    );
  }
}
