// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:admanyout/widgets/show_outline_button.dart';
import 'package:flutter/material.dart';

import 'package:admanyout/models/photo_model.dart';
import 'package:admanyout/models/post_model.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_image.dart';
import 'package:image_picker/image_picker.dart';

class AddNewImagePost extends StatefulWidget {
  final PostModel postModel;
  final String docIdPost;
  final List<PhotoModel> photoModels;
  const AddNewImagePost({
    Key? key,
    required this.postModel,
    required this.docIdPost,
    required this.photoModels,
  }) : super(key: key);

  @override
  State<AddNewImagePost> createState() => _AddNewImagePostState();
}

class _AddNewImagePostState extends State<AddNewImagePost> {
  PostModel? postModel;
  String? docIdPost;
  var photoModels = <PhotoModel>[];
  File? file;
  

  @override
  void initState() {
    super.initState();
    postModel = widget.postModel;
    docIdPost = widget.docIdPost;
    photoModels = widget.photoModels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          file == null
              ? newImage()
              : SizedBox(
                  width: 250,
                  height: 250,
                  child: Image.file(
                    file!,
                    fit: BoxFit.cover,
                  ),
                ),
          newControlCamera(),
          Expanded(
            child: GridView.builder(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: photoModels.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (BuildContext context, int index) => Image.network(
                      photoModels[index].urlPhoto,
                      fit: BoxFit.cover,
                    )),
          )
        ],
      ),
    );
  }

  Row newControlCamera() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ShowIconButton(
            iconData: Icons.add_a_photo,
            pressFunc: () => processTakePhoto(imageSource: ImageSource.camera)),
        ShowIconButton(
            iconData: Icons.add_photo_alternate,
            pressFunc: () =>
                processTakePhoto(imageSource: ImageSource.gallery)),
        // ShowOutlineButton(label: 'Stock', pressFunc: () {}),
      ],
    );
  }

  Future<void> processTakePhoto({required ImageSource imageSource}) async {
    var result = await ImagePicker().pickImage(
      source: imageSource,
      maxWidth: 800,
      maxHeight: 800,
    );
    setState(() {
      file = File(result!.path);
    });
  }

  Widget newImage() {
    return const ShowImage(
      path: 'images/image.png',
      width: 250,
    );
  }
}
