// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:admanyout/models/photo_model.dart';
import 'package:admanyout/models/post_model.dart';
import 'package:admanyout/widgets/show_outline_button.dart';

class EidtImagePost extends StatefulWidget {
  final PostModel postModel;
  final int indexImage;
  final List<PhotoModel> photoModels;
  final String docIdPost;
  const EidtImagePost({
    Key? key,
    required this.postModel,
    required this.indexImage,
    required this.photoModels,
    required this.docIdPost,
  }) : super(key: key);

  @override
  State<EidtImagePost> createState() => _EidtImagePostState();
}

class _EidtImagePostState extends State<EidtImagePost> {
  PostModel? postModel;
  int? indexImage;
  var photomodels = <PhotoModel>[];
  String? urlNewImage;
  String? docIdPost;

  @override
  void initState() {
    super.initState();
    postModel = widget.postModel;
    indexImage = widget.indexImage;
    photomodels = widget.photoModels;
    docIdPost = widget.docIdPost;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          urlNewImage == null
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ShowOutlineButton(
                      label: 'Edit',
                      pressFunc: () async {
                        print('docIdPost ==>> $docIdPost');

                        var urlPaths = postModel!.urlPaths;
                        urlPaths[indexImage!] = urlNewImage!;

                        Map<String, dynamic> data = {};
                        data['urlPaths'] = urlPaths;

                        await FirebaseFirestore.instance
                            .collection('post')
                            .doc(docIdPost)
                            .update(data)
                            .then((value) {
                          Navigator.pop(context);
                        });
                      }),
                ),
        ],
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Image.network(urlNewImage == null
              ? postModel!.urlPaths[indexImage!]
              : urlNewImage!),
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: photomodels.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                // mainAxisSpacing: 4,
                // crossAxisSpacing: 4,
              ),
              itemBuilder: (BuildContext context, int index) => InkWell(
                onTap: () {
                  print('you click index ==> $index');
                  urlNewImage = photomodels[index].urlPhoto;
                  setState(() {});
                },
                child: Image.network(
                  photomodels[index].urlPhoto,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
