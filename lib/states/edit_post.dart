// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
import 'package:admanyout/models/photo_model.dart';
import 'package:admanyout/states/add_new_image_post.dart';
import 'package:admanyout/states/edit_image_post.dart';
import 'package:admanyout/widgets/show_outline_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:admanyout/models/post_model.dart';
import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/widgets/show_icon_button.dart';

class EditPost extends StatefulWidget {
  final PostModel postModel;
  final String docIdPost;
  const EditPost({
    Key? key,
    required this.postModel,
    required this.docIdPost,
  }) : super(key: key);

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  PostModel? postModel;
  String? docIdPost;
  var photoModels = <PhotoModel>[];

  @override
  void initState() {
    super.initState();
    postModel = widget.postModel;
    docIdPost = widget.docIdPost;
    findPhotoModels();
  }

  Future<void> findPhotoModels() async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(postModel!.uidPost)
        .collection('photo')
        .get()
        .then((value) {
      for (var element in value.docs) {
        PhotoModel photoModel = PhotoModel.fromMap(element.data());
        photoModels.add(photoModel);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          newGridVew(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ShowOutlineButton(
                  label: '+',
                  pressFunc: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddNewImagePost(
                              postModel: postModel!, docIdPost: docIdPost!, photoModels: photoModels,),
                        )).then((value) {});
                  }),
              const SizedBox(
                width: 36,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget newGridVew() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemCount: postModel!.urlPaths.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          // mainAxisSpacing: 8,
          // crossAxisSpacing: 8,
          crossAxisCount: 3,
          childAspectRatio: 1.5),
      itemBuilder: (BuildContext context, int index) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 180,
            child: Stack(
              children: [
                Image.network(
                  postModel!.urlPaths[index],
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: postModel!.urlPaths.length == 1
                      ? const SizedBox()
                      : ShowIconButton(
                          iconData: Icons.delete_forever_outlined,
                          pressFunc: () {
                            MyDialog(context: context).twoActionDilalog(
                              title: 'Confirm Delete',
                              message: 'Are You Sure delete item ?',
                              label1: 'Comfirm',
                              label2: 'Cancel',
                              pressFunc1: () async {
                                var urlPaths = postModel!.urlPaths;
                                print('urlPaths ก่อนลบ ==> ${urlPaths.length}');

                                urlPaths.removeAt(index);
                                print('urlPaths หลังลบ ==> ${urlPaths.length}');

                                Map<String, dynamic> map = {};
                                map['urlPaths'] = urlPaths;

                                await FirebaseFirestore.instance
                                    .collection('post')
                                    .doc(docIdPost)
                                    .update(map)
                                    .then((value) async {
                                  print('Success Delete Image');

                                  await FirebaseFirestore.instance
                                      .collection('post')
                                      .doc(docIdPost)
                                      .get()
                                      .then((value) {
                                    postModel =
                                        PostModel.fromMap(value.data()!);
                                    Navigator.pop(context);
                                    setState(() {});
                                  });
                                });
                              },
                              pressFunc2: () {
                                Navigator.pop(context);
                              },
                              contentWidget:
                                  Image.network(postModel!.urlPaths[index]),
                            );
                          },
                        ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: ShowIconButton(
                    iconData: Icons.edit,
                    pressFunc: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EidtImagePost(
                              postModel: postModel!,
                              indexImage: index,
                              photoModels: photoModels,
                              docIdPost: docIdPost!,
                            ),
                          )).then((value) async {
                        var object = await FirebaseFirestore.instance
                            .collection('post')
                            .doc(docIdPost)
                            .get();
                        postModel = PostModel.fromMap(object.data()!);
                        setState(() {});
                      });

                      // MyDialog(context: context).twoActionDilalog(
                      //     title: 'Edit Image ?',
                      //     message: 'Please New Image',
                      //     label1: 'Edit',
                      //     label2: 'Cancel',
                      //     pressFunc1: () {
                      //       Navigator.pop(context);
                      //     },
                      //     pressFunc2: () {
                      //       Navigator.pop(context);
                      //     },
                      //     contentWidget: SingleChildScrollView(
                      //       child: Column(
                      //         children: [
                      //           Image.network(postModel!.urlPaths[index]),
                      //           SizedBox(
                      //             width: 300,
                      //             height: 300,
                      //             child: GridView.builder(
                      //               itemCount: photoModels.length,
                      //               shrinkWrap: true,
                      //               gridDelegate:
                      //                   const SliverGridDelegateWithFixedCrossAxisCount(
                      //                       crossAxisCount: 3),
                      //               itemBuilder:
                      //                   (BuildContext context, int index) =>
                      //                       InkWell(
                      //                 onTap: () {
                      //                   print('You tab at id ==> $index');
                      //                 },
                      //                 child: Image.network(
                      //                     photoModels[index].urlPhoto),
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ));
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
