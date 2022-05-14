import 'package:admanyout/widgets/show_text.dart';
import 'package:flutter/material.dart';

class ShowProgress extends StatelessWidget {
  const ShowProgress({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          color: Colors.white,
        ),
        SizedBox(height: 36,),
        ShowText(label: 'Loading ... Please wait')
      ],
    ));
  }
}
