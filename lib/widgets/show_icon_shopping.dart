import 'package:flutter/material.dart';

class ShowIconShopping extends StatelessWidget {
  const ShowIconShopping({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 36,height: 36,
      child: Image.asset('images/shopping.png'),
    );
  }
}
