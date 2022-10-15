import 'package:admanyout/models/sos_model.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/shop_progress.dart';
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
                  // fit: StackFit.expand,
                  children: [
                    Image.network(
                      sosModels[index].urlBig,
                      fit: BoxFit.cover,
                    ),
                    Positioned(top: 8,left: 8,
                      child: Container(
                        width: boxConstraints.maxWidth * 0.3,
                        height: boxConstraints.maxWidth * 0.3,
                        child: Image.network(sosModels[index].urlSmall, fit: BoxFit.cover,),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
  }

  Future<void> readSosData() async {
    await FirebaseFirestore.instance.collection('sos').get().then((value) {
      for (var element in value.docs) {
        SosModel sosModel = SosModel.fromMap(element.data());
        sosModels.add(sosModel);
      }

      load = false;
      setState(() {});
    });
  }
}
