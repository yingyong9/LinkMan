import 'package:admanyout/states/manage_my_link.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:flutter/material.dart';

class BaseManageMyLink extends StatefulWidget {
  const BaseManageMyLink({Key? key}) : super(key: key);

  @override
  State<BaseManageMyLink> createState() => _BaseManageMyLinkState();
}

class _BaseManageMyLinkState extends State<BaseManageMyLink> {
  var widgets = <Widget>[
    ManageMyLink(),
    ShowText(label: 'publish Link'),
  ];
  var tabsWidgets = <Widget>[
    Column(
      children: [
        Icon(
          Icons.link,
          color: Colors.white,
        ),
        ShowText(label: 'My Link'),
      ],
    ),
    Column(
      children: [Icon(Icons.public),
        ShowText(label: 'Publish Link'),
      ],
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            bottom: TabBar(tabs: tabsWidgets),
          ),
          body: TabBarView(children: widgets),
        ),
      ),
    );
  }
}
