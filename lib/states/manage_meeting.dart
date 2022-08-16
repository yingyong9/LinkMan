// ignore_for_file: avoid_print

import 'package:admanyout/models/room_model.dart';
import 'package:admanyout/states/add_room_meeting.dart';
import 'package:admanyout/utility/my_process.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_image.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManageMeeting extends StatefulWidget {
  const ManageMeeting({Key? key}) : super(key: key);

  @override
  State<ManageMeeting> createState() => _ManageMeetingState();
}

class _ManageMeetingState extends State<ManageMeeting> {
  var roomModels = <RoomModel>[];
  var titles = <String>[];
  var user = FirebaseAuth.instance.currentUser;

  var liveManLands = <String>[]; // keyRoom ที่ถูกจับจองไปแล้ว
  var showRooms = <bool>[];
  var liveRoomModels = <RoomModel?>[];

  @override
  void initState() {
    super.initState();

    readAllRoom();
  }

  void createArrayTitles() {
    for (var i = 1; i <= 15; i++) {
      String string = 'A$i';
      titles.add(string);
      showRooms.add(true);
      liveRoomModels.add(null);

      for (var element in roomModels) {
        if (string == element.keyRoom) {
          liveManLands.add(string);
          showRooms[i - 1] = false;
          liveRoomModels[i - 1] = element;
        }
      }
    }
    print('liveManLands ==> $liveManLands');
    print('showRooms ===> $showRooms');
    print('liveRoomModels ===> $liveRoomModels');
    setState(() {});
  }

  Future<void> readAllRoom() async {
    if (roomModels.isNotEmpty) {
      roomModels.clear();
      titles.clear();
      liveManLands.clear();
      liveRoomModels.clear();
    }

    await FirebaseFirestore.instance
        .collection('room')
        .where('uidOwner', isEqualTo: user!.uid)
        .get()
        .then((value) {
      for (var element in value.docs) {
        RoomModel roomModel = RoomModel.fromMap(element.data());
        roomModels.add(roomModel);
      }
      createArrayTitles();
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
      body: titles.isEmpty
          ? const ShowProgress()
          : GridView.builder(
              itemCount: titles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              itemBuilder: (context, index) => InkWell(
                onTap: () {
                  if (showRooms[index]) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddRoomMeeting(
                            liveManLand: titles[index],
                          ),
                        )).then((value) {
                      readAllRoom();
                    });
                  } else {
                    MyProcess()
                        .processLaunchUrl(url: liveRoomModels[index]!.linkRoom);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(border: Border.all()),
                  width: 120,
                  height: 120,
                  child: showRooms[index]
                      ? ShowText(
                          label: titles[index],
                          textStyle: MyStyle().h2Style(),
                        )
                      : Image.network(
                          liveRoomModels[index]!.urlImage,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
    );
  }

  Future<void> processChooseIdRoom({required int index}) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ListTile(
          leading: const SizedBox(
            width: 80,
            child: ShowImage(
              path: 'images/logo.png',
            ),
          ),
          title: ShowText(
            label: 'Room ${titles[index]}',
            textStyle: MyStyle().h2Style(),
          ),
        ),
      ),
    );
  }
}
