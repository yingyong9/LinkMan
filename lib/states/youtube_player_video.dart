import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerVideo extends StatefulWidget {
  const YoutubePlayerVideo({Key? key}) : super(key: key);

  @override
  State<YoutubePlayerVideo> createState() => _YoutubePlayerVideoState();
}

class _YoutubePlayerVideoState extends State<YoutubePlayerVideo> {
  String urlStream =
      'https://html.login.in.th/webrtc/player.php?dir=bGlua21hbg%3D%3D&id=bGlua21hbjAwMQ%3D%3D&showview=1';

  YoutubePlayerController? youtubePlayerController;

  String initialVideoId = 'Vns3jqxTpZc';

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = AndroidWebView();
    }

    youtubePlayerController = YoutubePlayerController(
      initialVideoId: initialVideoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: YoutubePlayer(
        controller: youtubePlayerController!,
        showVideoProgressIndicator: true,
        onReady: () {
          youtubePlayerController!.addListener(() {});
        },
      ),
    );
  }

  WebView newWebVew() {
    return WebView(
      initialUrl: urlStream,
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}
