import 'package:admanyout/models/photo_model.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_outline_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                            iconData: Icons.delete_forever, pressFunc: () {})
                        : const SizedBox(),
                    ShowOutlineButton(
                      label: displaySelect ? 'UnSelect' : 'Select',
                      pressFunc: () {
                        setState(() {
                          displaySelect = !displaySelect;
                        });
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
                              child: Checkbox(activeColor: Colors.red,
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
