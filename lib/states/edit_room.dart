// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/utility/my_process.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:flutter/material.dart';

import 'package:admanyout/models/room_model.dart';
import 'package:image_picker/image_picker.dart';

class EditRoom extends StatefulWidget {
  final RoomModel roomModel;
  const EditRoom({
    Key? key,
    required this.roomModel,
  }) : super(key: key);

  @override
  State<EditRoom> createState() => _EditRoomState();
}

class _EditRoomState extends State<EditRoom> {
  RoomModel? roomModel;
  File? file;

  @override
  void initState() {
    super.initState();
    roomModel = widget.roomModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) => SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: () {
                  MyDialog(context: context).twoActionDilalog(
                      title: 'เลือกภาพ',
                      message: 'โดยการ ถ่ายรูป หรือ เลือกภาพ',
                      label1: 'กล้อง',
                      label2: 'Gallery',
                      pressFunc1: () async {
                        Navigator.pop(context);
                        await MyProcess()
                            .processTakePhoto(source: ImageSource.camera)
                            .then((value) {
                          file = value;
                          setState(() {});
                        });
                      },
                      pressFunc2: () async {
                        Navigator.pop(context);
                        await MyProcess()
                            .processTakePhoto(source: ImageSource.gallery)
                            .then((value) {
                          file = value;
                          setState(() {});
                        });
                      });
                },
                behavior: HitTestBehavior.opaque,
                child: file == null
                    ? Image.network(
                        roomModel!.urlImage,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        file!,
                        fit: BoxFit.cover,
                      ),
              ),
              Positioned(
                top: 8,
                child: ShowIconButton(
                    iconData: Icons.arrow_back_ios,
                    color: Colors.white,
                    pressFunc: () {
                      Navigator.pop(context);
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
