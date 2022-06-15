import 'package:admanyout/states/add_photo_multi.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:flutter/material.dart';

class SearchShortCode extends StatelessWidget {
  const SearchShortCode({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: ShowText(
          label: 'LINKMAN',
          textStyle: MyConstant().h1Style(),
        ),
        actions: [
          ShowIconButton(size: 36,color: Color.fromARGB(255, 236, 12, 12),
            iconData: Icons.add_box_outlined,
            pressFunc: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // builder: (context) => const AddPhoto(),
                  builder: (context) => const AddPhotoMulti(),
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
    );
  }
}
