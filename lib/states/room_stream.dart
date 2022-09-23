import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:flutter/material.dart';

class RoomStream extends StatefulWidget {
  const RoomStream({Key? key}) : super(key: key);

  @override
  State<RoomStream> createState() => _RoomStreamState();
}

class _RoomStreamState extends State<RoomStream> {
  var linkRooms = <String>[
    'https://html.login.in.th/webrtc/?address=linkman&stream=linkman001&w=640&h=360#gethtml',
    'https://html.login.in.th/webrtc/?address=linkman&stream=linkman002&w=640&h=360#gethtml',
    'https://html.login.in.th/webrtc/?address=linkman&stream=linkman003&w=640&h=360#gethtml',
    'https://html.login.in.th/webrtc/?address=linkman&stream=linkman004&w=640&h=360#gethtml',
    'https://html.login.in.th/webrtc/?address=linkman&stream=linkman005&w=640&h=360#gethtml',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (context, index) => InkWell(
          onTap: () {
            processOpenLink();
          },
          child: Card(
              color: Colors.grey.shade300,
              child: ShowText(
                label: 'Room $index',
                textStyle: MyStyle().h2Style(),
              )),
        ),
        itemCount: 5,
      ),
    );
  }
  
  void processOpenLink() {}
}
