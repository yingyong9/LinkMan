import 'dart:io';
import 'dart:math';

import 'package:admanyout/models/photo_model.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_outline_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ManageMyPhoto extends StatefulWidget {
  const ManageMyPhoto({Key? key}) : super(key: key);

  @override
  State<ManageMyPhoto> createState() => _ManageMyPhotoState();
}

class _ManageMyPhotoState extends State<ManageMyPhoto> {
  var user = FirebaseAuth.instance.currentUser;
  bool load = true;
  bool? haveData;
  var photoModels = <PhotoModel>[];
  var selectImages = <bool>[];
  var docIdPhotos = <String>[];
  bool displaySelect = false;

  @override
  void initState() {
    super.initState();
    readAllMyPhoto();
  }

  Future<void> readAllMyPhoto() async {
    if (photoModels.isNotEmpty) {
      photoModels.clear();
      selectImages.clear();
      docIdPhotos.clear();
      displaySelect = false;
    }

    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .collection('photo')
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        haveData = false;
      } else {
        for (var element in value.docs) {
          PhotoModel photoModel = PhotoModel.fromMap(element.data());
          photoModels.add(photoModel);
          selectImages.add(false);
          docIdPhotos.add(element.id);
        }
        haveData = true;
      }

      load = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ShowIconButton(
          iconData: Icons.add_a_photo,
          pressFunc: () async {
            var result = await ImagePicker().pickImage(
              source: ImageSource.camera,
              maxWidth: 800,
              maxHeight: 800,
            );

            if (result != null) {
              File file = File(result.path);
              String nameFile =
                  '${user!.uid}${Random().nextInt(100000000)}.jpg';
              FirebaseStorage firebaseStorage = FirebaseStorage.instance;
              Reference reference =
                  firebaseStorage.ref().child('photo/$nameFile');
              UploadTask uploadTask = reference.putFile(file);
              await uploadTask.whenComplete(() async {
                await reference.getDownloadURL().then((value) async {
                  String urlPhoto = value;
                  print('urlPhoto ==>> $urlPhoto');

                  PhotoModel photoModel = PhotoModel(urlPhoto: urlPhoto);
                  await FirebaseFirestore.instance
                      .collection('user')
                      .doc(user!.uid)
                      .collection('photo')
                      .doc()
                      .set(photoModel.toMap())
                      .then((value) {
                    readAllMyPhoto();
                  });
                });
              });
            }
          }),
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                height: 40,
                child: Row(
                  children: [
                    displaySelect
                        ? ShowIconButton(
                            iconData: Icons.delete_forever,
                            pressFunc: () async {
                              for (var i = 0; i < selectImages.length; i++) {
                                if (selectImages[i]) {
                                  print(
                                      'delete at index ==> ${docIdPhotos[i]}');
                                  await FirebaseFirestore.instance
                                      .collection('user')
                                      .doc(user!.uid)
                                      .collection('photo')
                                      .doc(docIdPhotos[i])
                                      .delete()
                                      .then((value) {
                                    print(
                                        'delete at index ==> ${docIdPhotos[i]}');
                                  });
                                }
                              }
                              readAllMyPhoto();
                              setState(() {});
                            },
                          )
                        : const SizedBox(),
                    ShowOutlineButton(
                      label: displaySelect ? 'UnSelect' : 'Select',
                      pressFunc: () {
                        for (var i = 0; i < selectImages.length; i++) {
                          selectImages[i] = false;
                        }
                        displaySelect = !displaySelect;
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: load
          ? const ShowProgress()
          : haveData!
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      crossAxisCount: 3),
                  itemBuilder: (BuildContext context, int index) => Stack(
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: Image.network(
                          photoModels[index].urlPhoto,
                          fit: BoxFit.cover,
                        ),
                      ),
                      displaySelect
                          ? Theme(
                              data: Theme.of(context)
                                  .copyWith(unselectedWidgetColor: Colors.red),
                              child: Checkbox(
                                activeColor: Colors.red,
                                value: selectImages[index],
                                onChanged: (value) {
                                  setState(() {
                                    selectImages[index] = value!;
                                  });
                                },
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                  itemCount: photoModels.length,
                )
              : ShowText(
                  label: 'No Photo',
                  textStyle: MyConstant().h1Style(),
                ),
    );
  }
}
