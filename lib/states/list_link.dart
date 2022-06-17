// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:flutter/material.dart';

import 'package:admanyout/models/post_model2.dart';

class ListLink extends StatefulWidget {
  final PostModel2 postModel2;
  const ListLink({
    Key? key,
    required this.postModel2,
  }) : super(key: key);

  @override
  State<ListLink> createState() => _ListLinkState();
}

class _ListLinkState extends State<ListLink> {
  PostModel2? postModel2;
  var listWidgets = <List<Widget>>[];
  var listUrlLinks = <List<String>>[];

  @override
  void initState() {
    super.initState();
    postModel2 = widget.postModel2;
    createListWidget();
  }

  void createListWidget() {
    for (var element in postModel2!.nameLinkShow) {
      var widgets = <Widget>[];

      for (var i = 0; i < element.length; i++) {
        widgets.add(Row(
          children: [
            const SizedBox(
              width: 32,
            ),
            InkWell(
              onTap: () {

                

                print('You tab index ==> $i');

              },
              child: ShowText(
                label: element['name$i'],
              ),
            ),
          ],
        ));
      }

      listWidgets.add(widgets);
    }

    for (var element in postModel2!.link) {
      var urlLisks = <String>[];
      for (var i = 0; i < element.length; i++) {
        urlLisks.add(element['link$i']);
      }
      listUrlLinks.add(urlLisks);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: postModel2!.nameLink.length,
        itemBuilder: (context, index) => ExpansionTile(
          title: ShowText(
            label: postModel2!.nameLink[index],
            textStyle: MyConstant().h2Style(),
          ),
          children: listWidgets[index],
        ),
      ),
    );
  }
}
