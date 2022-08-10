import 'package:admanyout/models/category_room_model.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChooseCategoryRoom extends StatefulWidget {
  const ChooseCategoryRoom({Key? key}) : super(key: key);

  @override
  State<ChooseCategoryRoom> createState() => _ChooseCategoryRoomState();
}

class _ChooseCategoryRoomState extends State<ChooseCategoryRoom> {
  var categoryRoomModels = <CategoryRoomModel>[];

  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(),
      body: categoryRoomModels.isEmpty
          ? const ShowProgress()
          : ListView.builder(itemCount: categoryRoomModels.length,
              itemBuilder: (context, index) =>
                  ShowText(label: categoryRoomModels[index].category, textStyle: MyConstant().h3BlackStyle(),),
            ),
    );
  }
}
