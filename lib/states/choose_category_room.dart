import 'package:admanyout/models/category_room_model.dart';
import 'package:admanyout/states/add_room_meeting.dart';
import 'package:admanyout/states/manage_meeting.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_style.dart';
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

    addCategoryHome();
  }

  void addCategoryHome() {
    print('addCategory Work');
    if (categoryRoomModels.isNotEmpty) {
      categoryRoomModels.clear();
    }

    CategoryRoomModel categoryRoomModel =
        CategoryRoomModel(item: 0, category: 'Home', room: 0);
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
      backgroundColor: MyStyle.bgColor,
      appBar: AppBar(
        backgroundColor: MyStyle.bgColor,
        foregroundColor: MyStyle.dark,
        elevation: 0,
      ),
      body: categoryRoomModels.isEmpty
          ? const ShowProgress()
          : GridView.builder(itemCount: categoryRoomModels.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              itemBuilder: (context, index) => InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageMeeting(),
                      )).then((value) {
                    addCategoryHome();
                  });
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      
                      children: [
                        SizedBox(
                          child: SizedBox(
                            child: ShowText(
                              label: categoryRoomModels[index].category,
                              textStyle: MyConstant().h2BlackBBBStyle(),
                            ),
                          ),
                        ),
                        ShowText(
                          label: categoryRoomModels[index].room.toString(),
                          textStyle: MyConstant().h3RedStyle(),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
