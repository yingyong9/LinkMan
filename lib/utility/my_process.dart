import 'package:random_password_generator/random_password_generator.dart';
import 'package:url_launcher/url_launcher.dart';

class MyProcess {
  String createPassword() {
    final genPassword = RandomPasswordGenerator();
    String password = genPassword.randomPassword(
        letters: true,
        uppercase: true,
        numbers: true,
        specialChar: false,
        passwordLength: 6);

    print('password ====> $password');
    return password;
  }

  Future<void> processLaunchUrl({required String url}) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Cannot Launch';
    }
  }

  String cutWord({required String string, required int word}) {
    String result = string;
    if (result.length > word) {
      result = result.substring(0, word);
      result = '$result ...';
    }
    return result;
  }

  String showSource({required String string}) {
    String result = 'Other';

    String link = string;
    if (link.contains('facebook')) {
      result = 'facebook';
    }

    if (link.contains('tiktok')) {
      result = 'tiktok';
    }

    if (link.contains('lin.ee')) {
      result = 'line';
    }

    if (link.contains('fb.watch')) {
      result = 'facebook';
    }

    if (link.contains('instagram')) {
      result = 'instagram';
    }

    return result;
  }
}
