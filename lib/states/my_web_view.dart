// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyWebView extends StatefulWidget {
  final String linkRoom;
  const MyWebView({
    Key? key,
    required this.linkRoom,
  }) : super(key: key);

  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  String? linkRoom;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }

    // linkRoom = widget.linkRoom;
    linkRoom = 'https://us02web.zoom.us/j/86249501965?pwd=VXNyRDZGdzFCWFJDWVBTeUxVU3ZUQT09';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: Container(
            width: constraints.maxWidth * 0.75,
            height: constraints.maxWidth * 0.75,
            child: WebView(
              initialUrl: linkRoom,
            ),
          ),
        ),
      ),
    );
  }
}
