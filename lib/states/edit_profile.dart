import 'dart:io';

import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/widgets/show_form.dart';
import 'package:admanyout/widgets/show_image.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File? file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: ShowText(
          label: 'แก้ไขโปรไฟร์',
          textStyle: MyConstant().h2Style(),
        ),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            children: [
              SizedBox(
                width: constraints.maxWidth * 0.75,
                height: constraints.maxWidth * 0.75,
                child: InkWell(
                  onTap: () {
                    print('u click');
                    MyDialog(context: context).twoActionDilalog(
                      title: 'กรุณาเลือกรูป',
                      message: 'คุณสามารถเลือกรูป จาก การถ่ายภาพ หรือ คลังภาพ',
                      label1: 'Camera',
                      label2: 'Gallery',
                      pressFunc1: () {
                        Navigator.pop(context);
                        processTakePhoto(source: ImageSource.camera);
                      },
                      pressFunc2: () {
                        Navigator.pop(context);
                        processTakePhoto(source: ImageSource.gallery);
                      },
                    );
                  },
                  child: const ShowImage(),
                ),
              ),
              ShowForm(
                  label: 'ชื่อ :',
                  iconData: Icons.fingerprint,
                  changeFunc: (String string) {}),
            ],
          );
        }),
      ),
    );
  }

  Future<void> processTakePhoto({required ImageSource source}) async {
    
  }
}
