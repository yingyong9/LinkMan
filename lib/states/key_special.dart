import 'package:admanyout/models/special_model.dart';
import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeySpecial extends StatefulWidget {
  const KeySpecial({Key? key}) : super(key: key);

  @override
  State<KeySpecial> createState() => _KeySpecialState();
}

class _KeySpecialState extends State<KeySpecial> {
  OtpFieldController controller = OtpFieldController();
  var specialModels = <SpecialModel>[];

  @override
  void initState() {
    super.initState();
    readKeySpecial();
  }

  Future<void> readKeySpecial() async {
    var user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .collection('special')
        .orderBy('expire', descending: true)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        MyDialog(context: context).normalActionDilalog(
            title: 'NO Key',
            message: 'ติดต่อ Admin หา key',
            label: 'Back',
            pressFunc: () {
              Navigator.pop(context);
              Navigator.pop(context);
            });
      } else {
        for (var item in value.docs) {
          SpecialModel specialModel = SpecialModel.fromMap(item.data());
          print('specialModel ==>> ${specialModel.toMap()}');
          specialModels.add(specialModel);
        }
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child:
            specialModels.isEmpty ? const ShowProgress() : newOTPTexrtField(),
      ),
    );
  }

  OTPTextField newOTPTexrtField() {
    return OTPTextField(
      keyboardType: TextInputType.text,
      fieldStyle: FieldStyle.box,
      fieldWidth: 30,
      length: 6,
      width: 300,
      controller: controller,
      onCompleted: (String string) {
        print('string ==>> $string');
        if (string == specialModels[0].key) {
          MyDialog(context: context).normalActionDilalog(
              title: 'Key ถูกต้อง',
              message: 'ยินดีต้อนรับ key ถูกต้อง',
              label: 'OK',
              pressFunc: () async {
                Navigator.pop(context);
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                preferences.clear();
                preferences
                    .setString('special', string)
                    .then((value) => Navigator.pop(context));
              });
        } else {
          MyDialog(context: context).normalActionDilalog(
              title: 'Key ไม่ถูกต้อง',
              message: 'กรุณากรอก key ใหม่',
              label: 'OK',
              pressFunc: () {
                Navigator.pop(context);
                controller.clear();
              });
        }
      },
    );
  }
}
