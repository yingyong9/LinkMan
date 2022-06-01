import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class AddPhotoMulti extends StatefulWidget {
  const AddPhotoMulti({Key? key}) : super(key: key);

  @override
  State<AddPhotoMulti> createState() => _AddPhotoMultiState();
}

class _AddPhotoMultiState extends State<AddPhotoMulti> {
  List<AssetEntity> assetEntitys = [];

  Future<void> selectMultiImages() async {
    var result = await AssetPicker.pickAssets(context,
        pickerConfig: const AssetPickerConfig(maxAssets: 20));
    if (result!.isNotEmpty) {
      assetEntitys.addAll(result);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    selectMultiImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: assetEntitys.isEmpty
          ? const SizedBox()
          : GridView.builder(
              // shrinkWrap: true,
              // physics: const ScrollPhysics(),
              itemCount: assetEntitys.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              itemBuilder: (BuildContext context, int index) =>
                  AssetEntityImage(
                assetEntitys[index],
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
    );
  }
}
