import 'package:admanyout/body/discovery.dart';
import 'package:admanyout/body/my_friend.dart';
import 'package:flutter/material.dart';

class MainNotiPost extends StatefulWidget {
  const MainNotiPost({Key? key}) : super(key: key);

  @override
  State<MainNotiPost> createState() => _MainNotiPostState();
}

class _MainNotiPostState extends State<MainNotiPost> {
  var bodys = <Widget>[];

  @override
  void initState() {
    super.initState();
    bodys.add(const MyFriend());
    bodys.add(const Discovery());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
