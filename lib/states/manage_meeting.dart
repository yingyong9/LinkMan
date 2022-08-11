import 'package:admanyout/models/room_model.dart';
import 'package:admanyout/states/add_room_meeting.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageMeeting extends StatefulWidget {
  const ManageMeeting({Key? key}) : super(key: key);

  @override
  State<ManageMeeting> createState() => _ManageMeetingState();
}

class _ManageMeetingState extends State<ManageMeeting> {
  var roomModels = <RoomModel>[];

  @override
  void initState() {
    super.initState();
    readAllRoom();
  }

  Future<void> readAllRoom() async {
    if (roomModels.isNotEmpty) {
      roomModels.clear();
    }

    await FirebaseFirestore.instance.collection('room').get().then((value) {
      for (var element in value.docs) {
        RoomModel roomModel = RoomModel.fromMap(element.data());
        roomModels.add(roomModel);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyStyle.bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MyStyle.bgColor,
        foregroundColor: MyStyle.dark,
      ),
      floatingActionButton: ShowIconButton(
        color: Colors.red,
        size: 48,
        iconData: Icons.add_box,
        pressFunc: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddRoomMeeting(),
              )).then((value) {
            readAllRoom();
          });
        },
      ),
      body: roomModels.isEmpty
          ? const ShowProgress()
          : GridView.builder(
              itemCount: roomModels.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              itemBuilder: (context, index) => SizedBox(
                width: 120,
                height: 120,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    roomModels[index].urlImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
    );
  }
}
