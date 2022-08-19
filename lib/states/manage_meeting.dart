// ignore_for_file: avoid_print

import 'package:admanyout/models/room_model.dart';
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/states/add_room_meeting.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/utility/my_process.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_circle_image.dart';
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
  var userModels = <UserModel?>[];

  ScrollController scrollController = ScrollController();
  int factor = 1;

  @override
  void initState() {
    super.initState();
    setupScrollController();
    readAllRoom();
  }

  void setupScrollController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        factor++;
        print('### scrollMax factor ==> $factor ###');
        readAllRoom();
      }
    });
  }

  Future<void> createArrayTitles() async {
    for (var i = 0; i < 15 * factor; i++) {
      String string = 'A${i + 1}';
      titles.add(string);
      showRooms.add(true);
      liveRoomModels.add(null);
      userModels.add(null);

      for (var element in roomModels) {
        if (string == element.keyRoom) {
          liveManLands.add(string);
          showRooms[i] = false;
          liveRoomModels[i] = element;
          UserModel userModel =
              await MyFirebase().findUserModel(uid: element.uidOwner);
          userModels[i] = userModel;
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
      userModels.clear();
    }

    await FirebaseFirestore.instance
        .collection('room')
        .get()
        .then((value) async {
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
              controller: scrollController,
              itemCount: titles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 120 / 200,
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) => GestureDetector(
                behavior: HitTestBehavior.opaque,
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
                  decoration: BoxDecoration(
                    border: Border.all(color: MyStyle.dark),
                  ),
                  width: 120,
                  height: 200,
                  child: showRooms[index]
                      ? Stack(
                          children: [
                            ShowText(
                              label: titles[index],
                              textStyle: MyStyle().h2Style(),
                            ),
                            Container(
                              alignment: Alignment.center,
                              width: 120,
                              height: 200,
                              child: ShowText(
                                label: 'Click',
                                textStyle: MyStyle().h2Style(),
                              ),
                            )
                          ],
                        )
                      : Column(
                          children: [
                            Stack(
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: Image.network(
                                    liveRoomModels[index]!.urlImage,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5)),
                                  child: ShowText(
                                    label: titles[index],
                                    textStyle: MyStyle().h2Style(),
                                  ),
                                ),
                              ],
                            ),
                            showRooms[index]
                                ? const SizedBox()
                                : Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                print('You Tap Avatar');
                                              },
                                              child: ShowCircleImage(
                                                path:
                                                    userModels[index]?.avatar ??
                                                        MyConstant.urlLogo,
                                                radius: 12,
                                              ),
                                            ),
                                            ShowText(
                                                label:
                                                    userModels[index]?.name ??
                                                        ''),
                                          ],
                                        ),
                                        ShowText(
                                            label: liveRoomModels[index]
                                                    ?.nameRoom ??
                                                ''),
                                      ],
                                    ),
                                  ),
                          ],
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
