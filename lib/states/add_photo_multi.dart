// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:admanyout/models/photo_model.dart';
import 'package:admanyout/states/add_form.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class AddPhotoMulti extends StatefulWidget {
  const AddPhotoMulti({Key? key}) : super(key: key);

  @override
  State<AddPhotoMulti> createState() => _AddPhotoMultiState();
}

class _AddPhotoMultiState extends State<AddPhotoMulti> {
  List<AssetEntity> assetEntitys = [];
  var user = FirebaseAuth.instance.currentUser;

  Future<void> selectMultiImages() async {
    var result = await AssetPicker.pickAssets(context,
        pickerConfig: AssetPickerConfig(
          maxAssets: 20,
        ));

    if (result!.isNotEmpty) {
      assetEntitys.addAll(result);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    selectMultiImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          ShowIconButton(
              iconData: Icons.add_box_outlined,
              pressFunc: () {
                selectMultiImages();
              }),
          ShowIconButton(
            iconData: Icons.arrow_forward_outlined,
            pressFunc: () {
              processUploadImage();
            },
          ),
        ],
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: assetEntitys.isEmpty
          ? const SizedBox()
          : GridView.builder(
              // shrinkWrap: true,
              // physics: const ScrollPhysics(),
              itemCount: assetEntitys.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              itemBuilder: (BuildContext context, int index) =>
                  AssetEntityImage(
                assetEntitys[index],
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
    );
  }

  Future<void> processUploadImage() async {
    var files = <File>[];
    var photoModels = <PhotoModel>[];

    for (var element in assetEntitys) {
      final File? file = await element.file;

      final filePath = file!.path;
      print('filePath ==> $filePath');
      final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
      print('lastIndex ===> $lastIndex');
      final splitted = filePath.substring(0, (lastIndex));
      print('splitted ==> $splitted');
      final outPath = '${splitted}_out${filePath.substring(lastIndex)}';
      print('outPath ==> $outPath');

      // final compressedImage = await FlutterImageCompress.compressAndGetFile(
      //   filePath,
      //   outPath,
      //   minWidth: 800,
      //   minHeight: 800,
      //   quality: 70,
      // );

      // var pathSmall = compressedImage!.path;
      // print('pathSmall ==>> $pathSmall');

      // var result = await FilePicker.platform.pickFiles(
      //   type: FileType.custom,
      //   allowedExtensions: ['jpg', 'jpeg', 'png', 'heic'],
      // );

      // File smallFile = File(result.files.single.path);

      String nameFile = '${user!.uid}${Random().nextInt(10000000)}.jpg';
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference reference = storage.ref().child('/post2/$nameFile');
      UploadTask uploadTask = reference.putFile(file);
      await uploadTask.whenComplete(() async {
        await reference.getDownloadURL().then((value) {
          String urlImage = value;
          print('urlImage ==>> $urlImage');

          PhotoModel photoModel = PhotoModel(urlPhoto: urlImage);
          photoModels.add(photoModel);
        });
      });
    }

    print('photoModels ==> ${photoModels.toString()}');
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddForm(photoModels: photoModels),
        ));
  }
}
