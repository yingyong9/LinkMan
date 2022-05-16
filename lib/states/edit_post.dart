// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:flutter/material.dart';

import 'package:admanyout/models/post_model.dart';

class EditPost extends StatefulWidget {
  final PostModel postModel;
  const EditPost({
    Key? key,
    required this.postModel,
  }) : super(key: key);

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  PostModel? postModel;

  @override
  void initState() {
    super.initState();
    postModel = widget.postModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: GridView.builder(
        itemCount: postModel!.urlPaths.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 8, crossAxisSpacing: 8, crossAxisCount: 3, childAspectRatio: 1.5),
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
                    child: ShowIconButton(
                      iconData: Icons.delete_forever_outlined,
                      pressFunc: () {},
                    ),
                  ),
                   Positioned(
                    bottom: 0,
                    left: 0,
                    child: ShowIconButton(
                      iconData: Icons.edit,
                      pressFunc: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
