import 'package:admanyout/models/room_model.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_button.dart';
import 'package:admanyout/widgets/show_form.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LiveManPage extends StatefulWidget {
  const LiveManPage({Key? key}) : super(key: key);

  @override
  State<LiveManPage> createState() => _LiveManPageState();
}

class _LiveManPageState extends State<LiveManPage> {
  var roomModels = <RoomModel>[];
  var controllers = <TextEditingController>[];
  var linkContactControllers = <TextEditingController>[];
  var nameRoomControllers = <TextEditingController>[];
  var passBools = <bool>[];

  @override
  void initState() {
    super.initState();
    readAllRoom();
  }

  Future<void> readAllRoom() async {
    if (roomModels.isNotEmpty) {
      roomModels.clear();
    }

    await FirebaseFirestore.instance
        .collection('room')
        .orderBy('idRoom')
        .get()
        .then((value) {
      for (var element in value.docs) {
        RoomModel roomModel = RoomModel.fromMap(element.data());
        roomModels.add(roomModel);

        TextEditingController textEditingController = TextEditingController();
        textEditingController.text = roomModel.linkRoom;
        controllers.add(textEditingController);

        TextEditingController linkContactController = TextEditingController();
        linkContactController.text = roomModel.linkContact;
        linkContactControllers.add(linkContactController);

        TextEditingController nameRoomController = TextEditingController();
        nameRoomController.text = roomModel.nameRoom;
        nameRoomControllers.add(nameRoomController);

        passBools.add(false);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShowText(
          label: 'Live Man',
          textStyle: MyStyle().h2Style(),
        ),
        actions: [
          ShowIconButton(
            color: MyStyle.dark,
            iconData: Icons.add_circle,
            pressFunc: () {},
          )
        ],
      ),
      body: roomModels.isEmpty
          ? const ShowProgress()
          : LayoutBuilder(builder: (context, BoxConstraints boxConstraints) {
              return ListView.builder(
                itemCount: roomModels.length,
                itemBuilder: (context, index) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  margin:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  decoration: MyStyle().curveBorderBox(),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 4),
                            width: boxConstraints.maxWidth * 0.5 - 13,
                            height: boxConstraints.maxWidth * 0.4,
                            child: Image.network(
                              roomModels[index].urlImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 4),
                            width: boxConstraints.maxWidth * 0.5 - 13,
                            // height: boxConstraints.maxWidth * 0.4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                newIdRoom(index),
                                // ShowText(label: roomModels[index].linkRoom, textStyle: MyStyle().h3Style(),),
                                ShowForm(
                                  colorTheme: MyStyle.dark,
                                  controller: controllers[index],
                                  label: 'LinkRoom',
                                  iconData: Icons.android,
                                  changeFunc: (p0) {},
                                ),
                                ShowForm(
                                  colorTheme: MyStyle.dark,
                                  controller: linkContactControllers[index],
                                  label: 'LinkContact',
                                  iconData: Icons.contact_mail,
                                  changeFunc: (p0) {},
                                ),
                                ShowForm(
                                  colorTheme: MyStyle.dark,
                                  controller: nameRoomControllers[index],
                                  label: 'อยากบอกอะไร',
                                  iconData: Icons.question_answer,
                                  changeFunc: (p0) {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SwitchListTile(
                        title: passBools[index]
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: ShowButton(
                                      label: 'กดรับรหัส',
                                      pressFunc: () {},
                                    ),
                                  ),
                                ],
                              )
                            : ShowText(
                                label: 'เปิดใช้รหัสผ่าน',
                                textStyle: MyStyle().h3Style(),
                              ),
                        controlAffinity: ListTileControlAffinity.leading,
                        value: passBools[index],
                        onChanged: (value) {
                          passBools[index] = value;
                          setState(() {});
                        },
                      )
                    ],
                  ),
                ),
              );
            }),
    );
  }

  Row newIdRoom(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: ShowText(
            label: 'Live ManID:',
            textStyle: MyStyle().h2Style(),
          ),
        ),
        Expanded(
          flex: 1,
          child: ShowText(
            label: roomModels[index].idRoom,
            textStyle: MyStyle().h2Style(),
          ),
        ),
      ],
    );
  }
}
