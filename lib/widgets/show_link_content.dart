// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:admanyout/utility/my_process.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:admanyout/widgets/show_text_button.dart';

class ShowLinkContent extends StatelessWidget {
  const ShowLinkContent({
    Key? key,
    required this.string,
    this.colorText,
  }) : super(key: key);

  final String string;
  final Color? colorText;

  @override
  Widget build(BuildContext context) {
    var result = string.contains('https://');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: MyStyle().bgCircleGrey(),
      width: 200,
      child: result
          ? isLink(string: string)
          : ShowText(
              label: string,
              textStyle: MyStyle().h3Style(colorText: colorText),
            ),
    );
  }

  Widget isLink({required String string}) {
    var strings = string.split(' ');
    print('##4nov strings = $strings');

    String? urlLink;
    String text = '';
    String endText = '';

    for (var element in strings) {
      if (element.contains('https://')) {
        urlLink = element;
      } else {
        if (urlLink?.isEmpty ?? true) {
          text = '$text $element';
        } else {
          endText = '$endText $element';
        }
      }
    }

    print('##4nov urlLink ==> $urlLink');
    print('##4nov text = $text');

    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShowText(
            label: text,
            textStyle: MyStyle().h3Style(),
          ),
          ShowTextButton(
            label: urlLink!,
            pressFunc: () {
              MyProcess().processLaunchUrl(url: urlLink!);
            },
            textStyle: MyStyle().h3Style(colorText: Colors.blue.shade600),
          ),
          ShowText(
            label: endText,
            textStyle: MyStyle().h3Style(),
          ),
        ],
      ),
    );
  }
}
