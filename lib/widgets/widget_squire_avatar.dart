// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class WidgetSquireAvatar extends StatelessWidget {
  const WidgetSquireAvatar({
    Key? key,
    required this.urlImage,
  }) : super(key: key);

  final String urlImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 48,height: 48,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: Image.network(urlImage, fit: BoxFit.cover,),
      ),
    );
  }
}
