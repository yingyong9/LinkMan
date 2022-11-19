// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:admanyout/controllers/app_controller.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/show_button.dart';
import 'package:admanyout/widgets/show_form.dart';
import 'package:admanyout/widgets/show_form_long.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_text.dart';
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
      body: SafeArea(child:
          LayoutBuilder(builder: (context, BoxConstraints boxConstraints) {
        return GetX(
            init: AppController(),
            builder: (AppController appController) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    FocusScope.of(context).requestFocus(FocusScopeNode()),
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
                        Get.back();
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
                              child: ShowForm(
                                colorTheme: MyStyle.dark,
                                topMargin: 1,
                                changeFunc: (p0) {
                                  if (p0.isNotEmpty) {
                                    appController.textImage.value = p0.trim();
                                  } else {
                                    appController.textImage.value = '';
                                  }
                                },
                              ),
                            ),const SizedBox(width: 16,),
                            ShowButton(bgColor: const Color.fromARGB(255, 166, 232, 168),
                              label: 'Send',
                              pressFunc: () {
                                Get.back(result: appController.textImage.value);
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: boxConstraints.maxHeight * 0.5,
                      child: appController.textImage.value.isEmpty
                          ? const SizedBox()
                          : Container(
                              width: boxConstraints.maxWidth,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: MyStyle.dark.withOpacity(0.3)),
                              child: SingleChildScrollView(
                                child: ShowText(
                                  label: appController.textImage.value,
                                  textStyle: MyStyle().h1Style(
                                      color: MyStyle.bgColor, size: 24),
                                ),
                              ),
                            ),
                    )
                  ],
                ),
              );
            });
      })),
    );
  }
}
