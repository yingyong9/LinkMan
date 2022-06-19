// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_process.dart';
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
    for (var i = 0; i < postModel2!.nameLinkShow.length; i++) {
      var widgets = <Widget>[];
      var urlLisks = <String>[];

      for (var k = 0; k < postModel2!.link[i].length; k++) {
        urlLisks.add(postModel2!.link[i]['link$k']);
      }
      listUrlLinks.add(urlLisks);

      for (var j = 0; j < postModel2!.nameLinkShow[i].length; j++) {
        widgets.add(Row(
          children: [
            const SizedBox(
              width: 32,
            ),
            InkWell(
              onTap: () {
                print('You tab i= $i, j = $j');
                print('link ===>>> ${listUrlLinks[i][j]}');
                MyProcess().processLaunchUrl(url: listUrlLinks[i][j]);
              },
              child: Container(
                width: 300,
                child: Card(
                  color: Colors.grey.shade900,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ShowText(
                      label: postModel2!.nameLinkShow[i]['name$j'],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
      }

      listWidgets.add(widgets);
    }

    // for (var element in postModel2!.nameLinkShow) {

    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
           
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ShowText(
                    label: postModel2!.nameButton,
                    textStyle: MyConstant().h2WhiteBigStyle(),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.white,),
          ListView.builder(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemCount: postModel2!.nameLink.length,
            itemBuilder: (context, index) => ExpansionTile(
              title: Container(decoration: BoxDecoration(color: Colors.red),
                child: ShowText(
                  label: '${postModel2!.nameLink[index]} >',
                  textStyle: MyConstant().h2v2Style(),
                ),
              ),
              children: listWidgets[index],
            ),
          ),
        ],
      ),
    );
  }
}
