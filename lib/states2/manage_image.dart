// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/show_form_long.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManageImage extends StatefulWidget {
  const ManageImage({
    Key? key,
    required this.file,
  }) : super(key: key);

  final File file;

  @override
  State<ManageImage> createState() => _ManageImageState();
}

class _ManageImageState extends State<ManageImage> {
  File? file;

  @override
  void initState() {
    super.initState();
    file = widget.file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: SafeArea(child:
          LayoutBuilder(builder: (context, BoxConstraints boxConstraints) {
        return GestureDetector(behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).requestFocus(FocusScopeNode()),
          child: Stack(
            // fit: StackFit.expand,
            children: [
              SizedBox(
                width: boxConstraints.maxWidth,
                height: boxConstraints.maxHeight,
                child: Image.file(
                  file!,
                  fit: BoxFit.cover,
                ),
              ),
              ShowIconButton(
                iconData: Icons.arrow_back,
                pressFunc: () {
                  Get.back(result: 'Test Master Ung');
                },
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(color: MyStyle.bgColor),
                  width: boxConstraints.maxWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 240,
                        child: ShowFormLong(
                          marginTop: 1,
                          changeFunc: (p0) {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      })),
    );
  }
}
