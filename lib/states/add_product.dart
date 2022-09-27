import 'dart:io';

import 'package:admanyout/utility/my_process.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  File? file;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    takeProductPhoto();
  }

  Future<void> takeProductPhoto() async {
    file = await MyProcess().processTakePhoto(source: ImageSource.gallery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
