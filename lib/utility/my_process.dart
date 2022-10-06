import 'dart:io';
import 'dart:typed_data';

import 'package:admanyout/utility/my_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:random_password_generator/random_password_generator.dart';
import 'package:url_launcher/url_launcher.dart';

class MyProcess {
  
  Future<Position?> processFindPosition({required BuildContext context}) async {
    bool locationServiceEnable = await Geolocator.isLocationServiceEnabled();
    LocationPermission locationPermission;
    Position? position;

    if (locationServiceEnable) {
      // open service
      locationPermission = await Geolocator.checkPermission();

      if (locationPermission == LocationPermission.deniedForever) {
        processAlert(
            context: context,
            title: 'Permission Denied Forever',
            message: 'Please Share Location');
      } else {
        if (locationPermission == LocationPermission.denied) {
          locationPermission = await Geolocator.requestPermission();

          if ((locationPermission != LocationPermission.whileInUse) &&
              (locationPermission != LocationPermission.always)) {
            processAlert(
                context: context,
                title: 'Permission Denied Forever',
                message: 'Please Share Location');
          } else {
            //find Position
            position = await Geolocator.getCurrentPosition();
          }
        } else {
          //find Position
          position = await Geolocator.getCurrentPosition();
        }
      }
    } else {
      processAlert(
          context: context,
          title: 'Service Location Off',
          message: 'Please Open Location Service');
    }
    return position;
  }

  void processAlert(
      {required BuildContext context,
      required String title,
      required String message}) {
    MyDialog(context: context).normalActionDilalog(
      title: title,
      message: message,
      label: 'OK',
      pressFunc: () {
        exit(0);
      },
    );
  }

  Future<void> processSave(
      {required String urlSave, required String nameFile}) async {
    var response = await Dio()
        .get(urlSave, options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(response.data),
      quality: 60,
      name: nameFile,
    );
    if (result['isSuccess']) {
      Fluttertoast.showToast(msg: 'Save Success');
    } else {
      Fluttertoast.showToast(msg: 'Cannot Save QrCode');
    }
  }

  String timeStampToString({required Timestamp timestamp}) {
    DateTime dateTime = timestamp.toDate();
    DateFormat dateFormat = DateFormat('dd MMM HH:mm');
    String result = dateFormat.format(dateTime);
    return result;
  }

  Future<File> processTakePhoto({required ImageSource source}) async {
    var result = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
    );
    return File(result!.path);
  }

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
