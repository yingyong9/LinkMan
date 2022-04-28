import 'dart:io';
import 'dart:math';

import 'package:admanyout/models/photo_model.dart';
import 'package:admanyout/states/add_form.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_image.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPhoto extends StatefulWidget {
  const AddPhoto({Key? key}) : super(key: key);

  @override
  State<AddPhoto> createState() => _AddPhotoState();
}

class _AddPhotoState extends State<AddPhoto> {
  var files = <File>[];
  var widgets = <Widget>[];
  var photoModels = <PhotoModel>[];
  var choosePhotoModels = <PhotoModel>[];
  File? file;

  var user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    readPhotoStock();
  }

  Future<void> readPhotoStock() async {
    if (widgets.isNotEmpty) {
      widgets.clear();
      photoModels.clear();
    }
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .collection('photo')
        .get()
        .then((value) {
      print('value ==>> ${value.docs}');
      if (value.docs.isNotEmpty) {
        for (var item in value.docs) {
          PhotoModel photoModel = PhotoModel.fromMap(item.data());
          photoModels.add(photoModel);
          widgets.add(creatImageFromUrl(url: photoModel.urlPhoto));
        }
        setState(() {});
      }
    });
  }

  Widget creatImageFromUrl({required String url}) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Image.network(url),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('โพสต์ใหม่'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        actions: [
          ShowIconButton(
              iconData: Icons.arrow_forward,
              pressFunc: () {
                if (choosePhotoModels.isEmpty) {
                  MyDialog(context: context).normalActionDilalog(
                      title: 'No Photo ?',
                      message: 'Please Choose Photo',
                      label: 'OK',
                      pressFunc: () => Navigator.pop(context));
                } else {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddForm(photoModels: choosePhotoModels),
                      ),
                      (route) => false);
                }
              })
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxWidth * 0.75,
                child: choosePhotoModels.isEmpty
                    ? const ShowImage(
                        path: 'images/image.png',
                      )
                    : Stack(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: choosePhotoModels.length,
                            itemBuilder: (context, index) => Image.network(
                                choosePhotoModels[index].urlPhoto),
                          ),
                          Positioned(
                            bottom: 0,
                            child: Card(
                              color: Colors.black,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ShowText(
                                  label: '${choosePhotoModels.length}',
                                  textStyle: MyConstant().h2WhiteStyle(),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
              ),
              newTakePhoto(),
              widgets.isEmpty ? const SizedBox() : newGridPhoto(),
            ],
          ),
        );
      }),
    );
  }

  GridView newGridPhoto() {
    return GridView.builder(
      itemCount: widgets.length,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (BuildContext context, int index) => InkWell(
        onTap: () {
          print('You tab index ==> $index');
          choosePhotoModels.add(photoModels[index]);
          setState(() {});
        },
        child: widgets[index],
      ),
    );
  }

  Row newTakePhoto() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton(
          onPressed: () => processTakePhoto(imageSource: ImageSource.gallery),
          child: ShowText(
            label: 'Gallery',
            textStyle: MyConstant().h3WhiteStyle(),
          ),
        ),
        ShowIconButton(
          iconData: Icons.add_a_photo_outlined,
          pressFunc: () => processTakePhoto(imageSource: ImageSource.camera),
        )
      ],
    );
  }

  Future<void> processTakePhoto({required ImageSource imageSource}) async {
    var result = await ImagePicker().pickImage(
      source: imageSource,
      maxWidth: 800,
      maxHeight: 800,
    );
    file = File(result!.path);
    files.add(file!);

    String uidLogin = user!.uid;
    String namePhoto = '$user${Random().nextInt(1000000)}.jpg';
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    Reference reference = firebaseStorage.ref().child('photo/$namePhoto');
    UploadTask uploadTask = reference.putFile(file!);
    await uploadTask.whenComplete(() async {
      await reference.getDownloadURL().then((value) async {
        String urlPhoto = value;
        PhotoModel photoModel = PhotoModel(urlPhoto: urlPhoto);
        await FirebaseFirestore.instance
            .collection('user')
            .doc(uidLogin)
            .collection('photo')
            .doc()
            .set(photoModel.toMap())
            .then((value) {
          print('upload Photo Sucess');
          readPhotoStock();
        });
      });
    });

    setState(() {});
  }
}
