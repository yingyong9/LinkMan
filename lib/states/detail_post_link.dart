// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:admanyout/models/fast_link_model.dart';
import 'package:admanyout/states/search_shortcode.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_process.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailPostLink extends StatefulWidget {
  final String linkId;
  const DetailPostLink({
    Key? key,
    required this.linkId,
  }) : super(key: key);

  @override
  State<DetailPostLink> createState() => _DetailPostLinkState();
}

class _DetailPostLinkState extends State<DetailPostLink> {
  String? linkId;
  bool load = true;
  bool? haveData;
  FastLinkModel? fastLinkModel;

  @override
  void initState() {
    super.initState();
    linkId = widget.linkId;
    readDataFromFirebase();
  }

  Future<void> readDataFromFirebase() async {
    await FirebaseFirestore.instance
        .collection('fastlink')
        .where('linkId', isEqualTo: linkId)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        haveData = false;
      } else {
        haveData = true;

        for (var element in value.docs) {
          fastLinkModel = FastLinkModel.fromMap(element.data());
        }
      }
      load = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: load
          ? const ShowProgress()
          : haveData!
              ? LayoutBuilder(
                  builder: (context, BoxConstraints boxConstraints) {
                  return showContent(boxConstraints: boxConstraints);
                })
              : ShowText(
                  label: 'No Data',
                  textStyle: MyConstant().h1Style(),
                ),
    );
  }

  ShowIconButton iconBack(BuildContext context) {
    return ShowIconButton(
      iconData: Icons.arrow_back_ios,
      color: Colors.white,
      pressFunc: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const SearchShortCode(),
            ),
            (route) => false);
      },
    );
  }

  Widget showContent({required BoxConstraints boxConstraints}) {
    return GestureDetector(
      onTap: () {
        String linkUrl = fastLinkModel!.linkUrl;

        if (linkUrl.isNotEmpty) {
          Clipboard.setData(ClipboardData(text: fastLinkModel!.urlImage));

          MyProcess().processLaunchUrl(url: linkUrl).then((value) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchShortCode(),
                ),
                (route) => false);
          });
        }

        print('You Tap ');
      },
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(fastLinkModel!.urlImage),
                fit: BoxFit.cover)),
        width: boxConstraints.maxWidth,
        height: boxConstraints.maxHeight,
        child: Stack(
          children: [
            iconBack(context),
          ],
        ),
      ),
    );
  }
}
