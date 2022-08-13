// ignore_for_file: avoid_print

import 'package:admanyout/models/category_room_model.dart';
import 'package:admanyout/models/fast_link_model.dart';
import 'package:admanyout/states/add_room_meeting.dart';
import 'package:admanyout/states/manage_meeting.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:admanyout/widgets/show_text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChooseCategoryRoom extends StatefulWidget {
  const ChooseCategoryRoom({Key? key}) : super(key: key);

  @override
  State<ChooseCategoryRoom> createState() => _ChooseCategoryRoomState();
}

class _ChooseCategoryRoomState extends State<ChooseCategoryRoom> {
  var categoryRoomModels = <CategoryRoomModel>[];
  var fastLinkModels = <FastLinkModel>[];

  @override
  void initState() {
    super.initState();
    addCategoryHome();
    readAllFastLink();
  }

  Future<void> readAllFastLink() async {
    await FirebaseFirestore.instance.collection('fastlink').limit(10)
    .get().then((value) {
      for (var element in value.docs) {
        FastLinkModel fastLinkModel = FastLinkModel.fromMap(element.data());
        fastLinkModels.add(fastLinkModel);
      }
      print('จำนวนของ fastlinkModel ========> ${fastLinkModels.length}');
      setState(() {});
    });
  }

  void addCategoryHome() {
    print('addCategory Work');
    if (categoryRoomModels.isNotEmpty) {
      categoryRoomModels.clear();
    }

    CategoryRoomModel categoryRoomModel =
        CategoryRoomModel(item: 0, category: 'ทั้งหมด', room: 0);
    categoryRoomModels.add(categoryRoomModel);
    readAllCategory();
  }

  Future<void> readAllCategory() async {
    await FirebaseFirestore.instance
        .collection('categoryRoom')
        .orderBy('item')
        .get()
        .then((value) {
      for (var element in value.docs) {
        CategoryRoomModel categoryRoomModel =
            CategoryRoomModel.fromMap(element.data());
        categoryRoomModels.add(categoryRoomModel);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyStyle.dark,
      appBar: AppBar(
        backgroundColor: MyStyle.dark,
        foregroundColor:  MyStyle.bgColor,
        elevation: 0,
      ),
      body: categoryRoomModels.isEmpty
          ? const ShowProgress()
          : LayoutBuilder(builder: (context, BoxConstraints boxConstraints) {
              return ListView.builder(
                itemCount: categoryRoomModels.length,
                itemBuilder: (context, index) => Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: boxConstraints.maxWidth * 0.35,
                          child: ShowTextButton(
                            textStyle: MyConstant().h2WhiteStyle(),
                            label: categoryRoomModels[index].category,
                            pressFunc: () {},
                          ),
                        ),
                      ],
                    ),
                    index > 5
                        ? const SizedBox()
                        : fastLinkModels.isEmpty
                            ? const ShowProgress()
                            : SizedBox(
                                height: boxConstraints.maxWidth * 0.5,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  
                                  itemCount: fastLinkModels.length,
                                  itemBuilder: (context, index2) => Container(padding: const EdgeInsets.symmetric(horizontal: 2),
                                    width: boxConstraints.maxWidth*0.5,
                                    height: boxConstraints.maxWidth,
                                    child: Image.network(fastLinkModels[index2].urlImage, fit: BoxFit.cover,),
                                  ),
                                ),
                              ),
                  ],
                ),
              );
            }),
    );
  }
}
