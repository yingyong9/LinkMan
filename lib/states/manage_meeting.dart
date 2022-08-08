import 'package:admanyout/states/add_room_meeting.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:flutter/material.dart';

class ManageMeeting extends StatefulWidget {
  const ManageMeeting({Key? key}) : super(key: key);

  @override
  State<ManageMeeting> createState() => _ManageMeetingState();
}

class _ManageMeetingState extends State<ManageMeeting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: ShowIconButton(
        color: Colors.red,
        size: 48,
        iconData: Icons.add_box,
        pressFunc: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddRoomMeeting(),));
        },
      ),
    );
  }
}
