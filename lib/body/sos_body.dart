import 'package:admanyout/models/place_model.dart';
import 'package:admanyout/models/sos_model.dart';
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/states2/sos_comment.dart';
import 'package:admanyout/states2/sos_direction.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/utility/my_process.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_image.dart';
import 'package:admanyout/widgets/show_outline_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SosBody extends StatefulWidget {
  const SosBody({Key? key}) : super(key: key);

  @override
  State<SosBody> createState() => _SosBodyState();
}

class _SosBodyState extends State<SosBody> {
  bool load = true;
  var sosModels = <SosModel>[];
  var userModelOwnerSoss = <UserModel>[];
  var placeModels = <PlaceModel>[];
  var docIdSoss = <String>[];

  @override
  void initState() {
    super.initState();
    readSosData();
  }

  @override
  Widget build(BuildContext context) {
    return load
        ? const ShowProgress()
        : LayoutBuilder(builder: (context, BoxConstraints boxConstraints) {
            return ListView.builder(
              itemCount: sosModels.length,
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.red.shade700)),
                width: boxConstraints.maxWidth,
                height: boxConstraints.maxHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imageBig(index),
                    imageSmallGroup(boxConstraints, index),
                    sosIconButton(context, index),
                    contentBotton(context, docIdSos: docIdSoss[index]),
                  ],
                ),
              ),
            );
          });
  }

  Positioned contentBotton(BuildContext context, {required String docIdSos}) {
    return Positioned(
      bottom: 0,
      child: Row(
        children: [
          ShowIconButton(
            iconData: Icons.comment,
            pressFunc: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SosComment(
                      docIdSos: docIdSos,
                    ),
                  ));
            },
          ),
          ShowOutlineButton(
            label: 'ยังไม่ได้รับการช่วยเหลือ',
            pressFunc: () {},
          )
        ],
      ),
    );
  }

  Center sosIconButton(BuildContext context, int index) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SosDirection(sosModel: sosModels[index]),
                  ));
            },
            child: const ShowImage(
              path: 'images/sos.png',
            ),
          ),
          ShowText(
            label:
                '${placeModels[index].district} ${placeModels[index].subdistrict}',
            textStyle: MyStyle().h3WhiteStyle(),
          ),
          ShowText(
            label: placeModels[index].province,
            textStyle: MyStyle().h2Style(color: Colors.white),
          ),
          ShowText(
            label: sosModels[index].textHelp,
            textStyle: MyStyle().h1Style(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Positioned imageSmallGroup(BoxConstraints boxConstraints, int index) {
    return Positioned(
      top: 8,
      left: 8,
      child: Row(
        children: [
          Container(
            decoration: MyStyle().curveBorderBox(),
            width: boxConstraints.maxWidth * 0.3,
            height: boxConstraints.maxWidth * 0.3,
            child: Image.network(
              sosModels[index].urlSmall,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 8),
            height: boxConstraints.maxWidth * 0.3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShowText(
                  label: userModelOwnerSoss[index].name,
                  textStyle: MyStyle().h2Style(color: Colors.white),
                ),
                ShowText(
                  label: MyProcess()
                      .timeStampToString(timestamp: sosModels[index].timeSos),
                  textStyle: MyStyle().h3GreenBoldStyle(),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Image imageBig(int index) {
    return Image.network(
      sosModels[index].urlBig,
      fit: BoxFit.cover,
    );
  }

  Future<void> readSosData() async {
    await FirebaseFirestore.instance
        .collection('sos')
        .orderBy('timeSos', descending: true)
        .limit(5)
        .get()
        .then((value) async {
      for (var element in value.docs) {
        docIdSoss.add(element.id);

        SosModel sosModel = SosModel.fromMap(element.data());
        sosModels.add(sosModel);

        PlaceModel placeModel = await MyProcess().findPlaceData(
            lat: sosModel.sosGeopoint.latitude,
            lng: sosModel.sosGeopoint.longitude);
        placeModels.add(placeModel);

        UserModel userModel =
            await MyFirebase().findUserModel(uid: sosModel.uidSos);
        userModelOwnerSoss.add(userModel);
      }

      load = false;
      setState(() {});
    });
  }
}
