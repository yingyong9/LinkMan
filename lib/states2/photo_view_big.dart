// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';
import 'dart:math';

import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/utility/my_process.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewBig extends StatelessWidget {
  const PhotoViewBig({
    Key? key,
    required this.urlImage,
  }) : super(key: key);

  final String urlImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PhotoView(imageProvider: NetworkImage(urlImage)),
          ShowIconButton(
            iconData: Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
            pressFunc: () => Get.back(),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: ShowIconButton(
              iconData: Icons.file_download,
              pressFunc: () async {
                MyDialog(context: context).processDialog();

                await MyProcess()
                    .processSave(
                        urlSave: urlImage,
                        nameFile: 'image${Random().nextInt(1000)}.jpg')
                    .then((value) {
                  print('Save Success');
                  Navigator.pop(context);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
