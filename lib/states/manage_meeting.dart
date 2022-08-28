// ignore_for_file: avoid_print

import 'package:admanyout/models/room_model.dart';
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/states/add_room_meeting.dart';
import 'package:admanyout/states/edit_room.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/utility/my_process.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_circle_image.dart';
import 'package:admanyout/widgets/show_elevate_icon_button.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
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

  var liveManLands = <String?>[]; // keyRoom ที่ถูกจับจองไปแล้ว
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
      liveManLands.add(null);

      for (var element in roomModels) {
        if (string == element.keyRoom) {
          liveManLands[i] = string;
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
                childAspectRatio: 120 / 180,
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
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
                    if (liveRoomModels[index]!.onOffRoom) {
                      if (user!.uid == liveRoomModels[index]!.uidOwner) {
                        //Owner Click
                        print('Owner Click');
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditRoom(roomModel: liveRoomModels[index]!),));
                      } else {
                        //order Clck
                        MyProcess().processLaunchUrl(
                            url: liveRoomModels[index]!.linkRoom);
                      }
                    } else {
                      MyDialog(context: context).normalActionDilalog(
                          title: 'LiveLand Close',
                          message: 'Please Tap Message',
                          label: 'OK',
                          pressFunc: () {
                            Navigator.pop(context);
                          });
                    }
                  }
                },
                child: Container(
                  decoration: MyStyle()
                      .curveBorderBox(color: Colors.grey.shade600, curve: 10),
                  width: 120,
                  height: 180,
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
                              height: 180,
                              child: ShowText(
                                label: 'Click',
                                textStyle: MyStyle().h2Style(),
                              ),
                            )
                          ],
                        )
                      : Stack(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: Image.network(
                                liveRoomModels[index]!.urlImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: MyStyle().bgCircleBlack(),
                              child: ShowText(
                                label: titles[index],
                                textStyle:
                                    MyStyle().h2Style(color: Colors.white),
                              ),
                            ),
                            showRooms[index]
                                ? const SizedBox()
                                : Positioned(
                                    bottom: 8,
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            print('You Tap Avatar');
                                          },
                                          child: ShowCircleImage(
                                            path: userModels[index]?.avatar ??
                                                MyConstant.urlLogo,
                                            radius: 18,
                                          ),
                                        ),
                                        Container(
                                          decoration: const BoxDecoration(
                                              color: Colors.white),
                                          child: ShowText(
                                              textStyle: MyStyle().h2Style(),
                                              label: userModels[index]?.name ??
                                                  ''),
                                        ),
                                      ],
                                    ),
                                  ),
                            showRooms[index]
                                ? const SizedBox()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          newOnOffRoom(index),
                                          Container(
                                            // decoration:
                                            //     MyStyle().bgCircleBlack(),
                                            child: ShowIconButton(
                                              iconData: Icons.menu_book,
                                              pressFunc: () {},
                                            ),
                                          ),
                                          Container(
                                            // decoration:
                                            //     MyStyle().bgCircleBlack(),
                                            child: ShowIconButton(
                                              iconData: Icons.attach_email,
                                              pressFunc: () {},
                                            ),
                                          ),
                                          Container(
                                            // decoration:
                                            //     MyStyle().bgCircleBlack(),
                                            child: ShowIconButton(
                                              iconData: Icons.forum,
                                              pressFunc: () {},
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                ),
              ),
            ),
    );
  }

  Widget newOnOffRoom(int index) {
    return ShowElevateButton(
      pressFunc: () async {
        if (user!.uid == liveRoomModels[index]!.uidOwner) {
          print('Your Click liveManLand or keyRoom ==> ${liveManLands[index]}');
          var docIdRooms = await MyFirebase()
              .findDocIdRoomWhereKeyRoom(keyRoom: liveManLands[index]!);
          print('docIdRoos ==> $docIdRooms');

          Map<String, dynamic> map = liveRoomModels[index]!.toMap();
          map['onOffRoom'] = !liveRoomModels[index]!.onOffRoom;
          print('map ที่ต้องการจะอัพ ===>>> $map');

          await FirebaseFirestore.instance
              .collection('room')
              .doc(docIdRooms[0])
              .update(map)
              .then((value) {
            readAllRoom();
          });
        } else {
          print('คุณไม่ใช้ เจ้าของห้อง');
        }
      },
      iconData: Icons.radio_button_checked,
      label: liveRoomModels[index]!.onOffRoom ? 'Open' : 'Close',
      colorIcon: liveRoomModels[index]!.onOffRoom ? MyStyle.green : MyStyle.red,
      labelTextStyle: liveRoomModels[index]!.onOffRoom
          ? MyStyle().h3GreenStyle()
          : MyStyle().h3RedStyle(),
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
