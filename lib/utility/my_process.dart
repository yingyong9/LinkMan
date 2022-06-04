import 'package:url_launcher/url_launcher.dart';

class MyProcess {
  Future<void> processLaunchUrl({required String url}) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Cannot Launch';
    }
  }
}
