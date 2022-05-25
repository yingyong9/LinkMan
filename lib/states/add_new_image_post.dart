// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:math';

import 'package:admanyout/widgets/show_outline_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  bool displayAddImageButton = false;
  String urlNewImage = '';

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
        actions: [
          displayAddImageButton ? addImageButton() : const SizedBox(),
        ],
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          (file == null) && (urlNewImage.isEmpty)
              ? newImage()
              : urlNewImage.isNotEmpty
                  ? newImageFromMyPhoto()
                  : newImageCameraGallery(),
          newControlCamera(),
          Expanded(
            child: GridView.builder(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: photoModels.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (BuildContext context, int index) => InkWell(
                      onTap: () {
                        displayAddImageButton = true;
                        urlNewImage = photoModels[index].urlPhoto;
                        setState(() {});
                      },
                      child: Image.network(
                        photoModels[index].urlPhoto,
                        fit: BoxFit.cover,
                      ),
                    )),
          )
        ],
      ),
    );
  }

  Widget newImageFromMyPhoto() => SizedBox(
        width: 250,
        height: 250,
        child: Image.network(
          urlNewImage,
          fit: BoxFit.cover,
        ),
      );

  SizedBox newImageCameraGallery() {
    return SizedBox(
      width: 250,
      height: 250,
      child: Image.file(
        file!,
        fit: BoxFit.cover,
      ),
    );
  }

  Column addImageButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          height: 40,
          child: ShowOutlineButton(
            label: 'Add Image',
            pressFunc: () async {
              if (urlNewImage.isEmpty) {
                // uplaod image

                String nameFile =
                    '${postModel!.uidPost}${Random().nextInt(1000000)}.jpg';

                FirebaseStorage storage = FirebaseStorage.instance;
                Reference reference = storage.ref().child('photo/$nameFile');
                UploadTask uploadTask = reference.putFile(file!);
                await uploadTask.whenComplete(() async {
                  await reference.getDownloadURL().then((value) async {
                    urlNewImage = value;

                    PhotoModel model = PhotoModel(urlPhoto: urlNewImage);

                    await FirebaseFirestore.instance
                        .collection('user')
                        .doc(postModel!.uidPost)
                        .collection('photo')
                        .doc()
                        .set(model.toMap())
                        .then((value) {
                          processAddNewImageToFirebase();
                        });

                    
                  });
                });
              } else {
                processAddNewImageToFirebase();
              }
            },
          ),
        ),
      ],
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
    urlNewImage = '';
    displayAddImageButton = true;
    file = File(result!.path);
    setState(() {});
  }

  Widget newImage() {
    return const ShowImage(
      path: 'images/image.png',
      width: 250,
    );
  }

  Future<void> processAddNewImageToFirebase() async {
    print('##18may urlNewImage ==>> $urlNewImage');

    var urlPaths = postModel!.urlPaths;
    urlPaths.add(urlNewImage);
    Map<String, dynamic> data = {};
    data['urlPaths'] = urlPaths;

    await FirebaseFirestore.instance
        .collection('post')
        .doc(docIdPost)
        .update(data)
        .then((value) {
      Navigator.pop(context);
    });
  }
}
