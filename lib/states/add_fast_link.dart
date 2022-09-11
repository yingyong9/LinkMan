// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
import 'dart:io';
import 'dart:math';

import 'package:admanyout/models/category_room_model.dart';
import 'package:admanyout/models/fast_group_model.dart';
import 'package:admanyout/models/fast_link_model.dart';
import 'package:admanyout/models/room_model.dart';
import 'package:admanyout/models/song_model.dart';
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/states/search_shortcode.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_button.dart';
import 'package:admanyout/widgets/show_form.dart';
import 'package:admanyout/widgets/show_form_long.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class AddFastLink extends StatefulWidget {
  final String sixCode;
  final String addLink;

  const AddFastLink({
    Key? key,
    required this.sixCode,
    required this.addLink,
  }) : super(key: key);

  @override
  State<AddFastLink> createState() => _AddFastLinkState();
}

class _AddFastLinkState extends State<AddFastLink> {
  File? file;
  String? sixCode, addLink, detail, detail2, head;
  var user = FirebaseAuth.instance.currentUser;
  UserModel? userModelLogined;
  var fastGroupModels = <FastGroupModel>[];
  String? urlSongChoose;
  var urlSongModels = <SongModel>[];
  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  var categoryRoomModels = <CategoryRoomModel>[];
  CategoryRoomModel? chooseCategoryRoomModel;

  var roomModels = <RoomModel>[];
  RoomModel? chooseRoomModel;
  bool loadRoom = true;

  String? linkContact, nameButtonLinkContact;

  double? lat, lng;
  Map<MarkerId, Marker> markers = {};

  @override
  void initState() {
    super.initState();
    sixCode = widget.sixCode;
    addLink = widget.addLink;
    processGetImage();
    processFindUserLogined();
    processReadFastGroup();
    readSongFromData();
    readAllCategoryRoom();
    findKeyRoom();
  }

  Future<void> findKeyRoom() async {
    await FirebaseFirestore.instance
        .collection('room')
        .where('uidOwner', isEqualTo: user!.uid)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        //Status No Room
      } else {
        for (var element in value.docs) {
          RoomModel roomModel = RoomModel.fromMap(element.data());
          roomModels.add(roomModel);
        }
      }
      loadRoom = false;
      setState(() {});
    });
  }

  Future<void> readAllCategoryRoom() async {
    await FirebaseFirestore.instance
        .collection('categoryRoom')
        .get()
        .then((value) {
      for (var element in value.docs) {
        CategoryRoomModel categoryRoomModel =
            CategoryRoomModel.fromMap(element.data());
        categoryRoomModels.add(categoryRoomModel);
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    assetsAudioPlayer.dispose();
  }

  Future<void> readSongFromData() async {
    await FirebaseFirestore.instance.collection('song').get().then((value) {
      for (var element in value.docs) {
        SongModel songModel = SongModel.fromMap(element.data());
        urlSongModels.add(songModel);
      }
      setState(() {});
    });
  }

  Future<void> processReadFastGroup() async {
    if (fastGroupModels.isNotEmpty) {
      fastGroupModels.clear();
    }

    await FirebaseFirestore.instance
        .collection('fastGroup')
        .get()
        .then((value) {
      for (var element in value.docs) {
        FastGroupModel fastGroupModel = FastGroupModel.fromMap(element.data());
        fastGroupModels.add(fastGroupModel);
      }
      setState(() {});
    });
  }

  Future<void> processFindUserLogined() async {
    userModelLogined = await MyFirebase().findUserModel(uid: user!.uid);
    setState(() {});
  }

  Future<void> processGetImage() async {
    var result = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (result != null) {
      setState(() {
        file = File(result.path);
      });
    } else {
      processGetImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: newAppBar(),
      body: file == null
          ? const ShowProgress()
          : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints boxConstraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    FocusScope.of(context).requestFocus(FocusScopeNode()),
                child: ListView(
                  children: [
                    newImage(boxConstraints),
                    formDetail(
                      iconData: Icons.pin_drop_outlined,
                      iconPressFunc: () {
                        processFindLocation();
                      },
                      boxConstraints: boxConstraints,
                      label: 'Link คลิกหน้าจอ',
                      changeFunc: (p0) {
                        // addLink = p0.trim();
                      },
                    ),
                    lat == null
                        ? const SizedBox()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: MyConstant().curveBorderBox(),
                                width: boxConstraints.maxWidth * 0.6,
                                height: boxConstraints.maxWidth * 0.4,
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(lat!, lng!),
                                    zoom: 16,
                                  ),
                                  onMapCreated: (controller) {},
                                  markers: Set<Marker>.of(markers.values),
                                ),
                              ),
                            ],
                          ),
                    // formDetail(
                    //   boxConstraints: boxConstraints,
                    //   label: 'ชื่อปุ่มของ Link1',
                    //   changeFunc: (p0) {
                    //     nameButtonLinkContact = p0.trim();
                    //   },
                    // ),
                    addLink?.isEmpty ?? true
                        ? formDetail(
                            boxConstraints: boxConstraints,
                            label: 'Link ติดต่อ',
                            changeFunc: (p0) {
                              linkContact = p0.trim();
                            },
                          )
                        : Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                    userModelLogined!.avatar ??
                                        MyConstant.urlLogo),
                              ),
                              newTitle(
                                  boxConstraints: boxConstraints,
                                  string: addLink!),
                            ],
                          ),
                    // formDetail(
                    //     boxConstraints: boxConstraints,
                    //     label: 'ชื่อปุ่ม Link2 :',
                    //     changeFunc: (String string) {
                    //       head = string.trim();
                    //     }),

                         formDetail(
                      boxConstraints: boxConstraints,
                      label: 'Link3',
                      changeFunc: (p0) {},
                    ),
                     formDetail(
                      boxConstraints: boxConstraints,
                      label: 'ชื่อปุ่ม Link3',
                      changeFunc: (p0) {},
                    ),
                     formDetail(
                      boxConstraints: boxConstraints,
                      label: 'Link4',
                      changeFunc: (p0) {},
                    ),
                     formDetail(
                      boxConstraints: boxConstraints,
                      label: 'ชื่อปุ่ม Link4',
                      changeFunc: (p0) {},
                    ),
                     formDetail(
                      boxConstraints: boxConstraints,
                      label: 'Link5',
                      changeFunc: (p0) {},
                    ),
                     formDetail(
                      boxConstraints: boxConstraints,
                      label: 'ชื่อปุ่ม Link5',
                      changeFunc: (p0) {},
                    ),
                     formDetail(
                      boxConstraints: boxConstraints,
                      label: 'Link6',
                      changeFunc: (p0) {},
                    ),
                     formDetail(
                      boxConstraints: boxConstraints,
                      label: 'ชื่อปุ่ม Link6',
                      changeFunc: (p0) {},
                    ),
                        
                    formDetail(
                        boxConstraints: boxConstraints,
                        label: 'อยากบอกอะไร :',
                        changeFunc: (String string) {
                          detail = string.trim();
                        }),
                    formDetail(
                        boxConstraints: boxConstraints,
                        label: 'อยากบอกอะไร :',
                        changeFunc: (String string) {
                          detail2 = string.trim();
                        }),
                    loadRoom
                        ? const ShowProgress()
                        : roomModels.isEmpty
                            ? const SizedBox()
                            : dropDownLiveManLand(boxConstraints),
                   
                    newGroup(boxConstraints: boxConstraints),
                  ],
                ),
              );
            }),
    );
  }

  Row dropDownLiveManLand(BoxConstraints boxConstraints) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 8),
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(border: Border.all()),
          width: boxConstraints.maxWidth * 0.6,
          child: DropdownButton<dynamic>(
            isExpanded: true,
            hint: ShowText(
              label: 'เลือก LiveManLand',
              textStyle: MyConstant().h3BlackStyle(),
            ),
            value: chooseRoomModel,
            items: roomModels
                .map(
                  (e) => DropdownMenuItem(
                    child: ShowText(
                      label: e.keyRoom,
                      textStyle: MyConstant().h3BlackStyle(),
                    ),
                    value: e,
                  ),
                )
                .toList(),
            onChanged: (value) {
              chooseRoomModel = value;
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget newSong() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(),
      ),
      child: Column(
        children: [
          RadioListTile(
            title: ShowText(
              label: 'Song1',
              textStyle: MyConstant().h3BlackStyle(),
            ),
            value: urlSongModels[0].url,
            groupValue: urlSongChoose,
            onChanged: (value) {
              setState(() {
                urlSongChoose = value.toString();
                processPlaySong();
              });
            },
          ),
          RadioListTile(
            title: ShowText(
              label: 'Song2',
              textStyle: MyConstant().h3BlackStyle(),
            ),
            value: urlSongModels[1].url,
            groupValue: urlSongChoose,
            onChanged: (value) {
              setState(() {
                urlSongChoose = value.toString();
                processPlaySong();
              });
            },
          ),
          RadioListTile(
            title: ShowText(
              label: 'Song3',
              textStyle: MyConstant().h3BlackStyle(),
            ),
            value: urlSongModels[2].url,
            groupValue: urlSongChoose,
            onChanged: (value) {
              setState(() {
                urlSongChoose = value.toString();
                processPlaySong();
              });
            },
          ),
          RadioListTile(
            title: ShowText(
              label: 'Nothing',
              textStyle: MyConstant().h3BlackStyle(),
            ),
            value: '',
            groupValue: urlSongChoose,
            onChanged: (value) {
              setState(() {
                urlSongChoose = value.toString();
                processPlaySong();
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> processPlaySong() async {
    print('urlSong ===> $urlSongChoose');

    await assetsAudioPlayer.stop().then((value) async {
      if (urlSongChoose!.isNotEmpty) {
        await assetsAudioPlayer
            .open(Audio.network(urlSongChoose!))
            .then((value) {});
      }
    });

    try {} catch (e) {
      print('Error processPlaySong ===>> $e');
    }
  }

  Widget newGroup({required BoxConstraints boxConstraints}) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage:
                NetworkImage(userModelLogined!.avatar ?? MyConstant.urlLogo),
          ),
          const SizedBox(
            width: 16,
          ),
          SizedBox(
            width: boxConstraints.maxWidth * 0.65,
            child: buttonPost(),
          ),
        ],
      ),
    );
  }

  SizedBox buttonPost() {
    return SizedBox(
      child: ShowButton(
        label: 'Post >',
        pressFunc: () {
          if (detail?.isEmpty ?? true) {
            detail = '';
          }
          processUploadAndInsertFastLink();
        },
      ),
    );
  }

  Future<void> processUploadAndInsertFastLink() async {
    MyDialog(context: context).processDialog();

    String nameImage = '${user!.uid}${Random().nextInt(1000000)}.jpg';

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference reference = storage.ref().child('photofast/$nameImage');
    UploadTask uploadTask = reference.putFile(file!);
    await uploadTask.whenComplete(() async {
      await reference.getDownloadURL().then((value) async {
        String urlImage = value;

        DateTime dateTime = DateTime.now();
        Timestamp timestamp = Timestamp.fromDate(dateTime);

        GeoPoint position;

        if (lat == null) {
          position = const GeoPoint(0, 0);
        } else {
          position = GeoPoint(lat!, lng!);
        }

        FastLinkModel fastLinkModel = FastLinkModel(
          urlImage: urlImage,
          detail: detail ?? '',
          linkId: sixCode!,
          uidPost: user!.uid,
          linkUrl: addLink!,
          timestamp: timestamp,
          detail2: detail2 ?? '',
          head: head ?? '',
          urlSong: urlSongChoose ?? '',
          keyRoom: chooseRoomModel?.keyRoom ?? '',
          linkContact: linkContact ?? '',
          nameButtonLinkContact: nameButtonLinkContact ?? '',
          position: position,
        );

        print('fastLinkModel ==> ${fastLinkModel.toMap()}');

        await FirebaseFirestore.instance
            .collection('fastlink')
            .doc()
            .set(fastLinkModel.toMap())
            .then((value) {
          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchShortCode(),
              ),
              (route) => false);
        });
      });
    });
  }

  Widget formDetail({
    required BoxConstraints boxConstraints,
    required String label,
    required Function(String) changeFunc,
    IconData? iconData,
    Function()? iconPressFunc,
    Color? textColor,
   
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      // height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage:
                NetworkImage(userModelLogined!.avatar ?? MyConstant.urlLogo),
          ),
          const SizedBox(
            width: 16,
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            width: iconData == null
                ? boxConstraints.maxWidth * 0.65
                : boxConstraints.maxWidth * 0.65 - 15,
            child: ShowFormLong(
              marginTop: 0,
              label: label,
              changeFunc: changeFunc,
            ),
          ),
          iconData == null
              ? const SizedBox()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: iconPressFunc,
                        icon: Icon(
                          iconData,
                          size: 48,
                        )),
                    const SizedBox(
                      height: 8,
                    ),
                    ShowText(
                      label: 'ต่ำแหน่งที่ตั้ง',
                      textStyle: MyStyle().h3Style(),
                    )
                  ],
                ),
        ],
      ),
    );
  }

  Row formAddNewGroupFastPost(BoxConstraints boxConstraints) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          width: boxConstraints.maxWidth * 0.65,
          child: ShowForm(
            colorTheme: Colors.black,
            label: 'groupFastPost :',
            iconData: Icons.details_outlined,
            changeFunc: (String string) {},
          ),
        ),
      ],
    );
  }

  Row newTitle(
      {required BoxConstraints boxConstraints, required String string}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          width: boxConstraints.maxWidth * 0.65,
          decoration: MyConstant().curveBorderBox(),
          child: ShowText(
            label: string,
            textStyle: MyConstant().h3BlackStyle(),
          ),
        ),
      ],
    );
  }

  Row newImage(BoxConstraints boxConstraints) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              width: boxConstraints.maxWidth * 0.65,
              height: boxConstraints.maxWidth * 0.65,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: FileImage(file!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ShowIconButton(
              iconData: Icons.add_photo_alternate,
              pressFunc: () {
                processGetImage();
              },
            ),
          ],
        ),
      ],
    );
  }

  AppBar newAppBar() {
    return AppBar(
      leading: ShowIconButton(
          color: Colors.black,
          iconData: Icons.arrow_back_ios,
          pressFunc: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchShortCode(),
                ),
                (route) => false);
          }),
      title: Text(widget.sixCode),
      foregroundColor: Colors.black,
      elevation: 0,
      backgroundColor: Colors.white,
    );
  }

  Future<void> processFindLocation() async {
    LocationPermission locationPermission;

    bool locationServiceEnable = await Geolocator.isLocationServiceEnabled();

    if (locationServiceEnable) {
      locationPermission = await Geolocator.checkPermission();

      if (locationPermission == LocationPermission.deniedForever) {
        MyDialog(context: context).normalActionDilalog(
            title: 'ปิดกันการแชร์ต่ำแหน่ง อยู่',
            message: 'กรุณาเปิด ด้วยคะ',
            label: 'ไปเปิด การแชร์ต่ำแหน่ง',
            pressFunc: () {
              Geolocator.openAppSettings();
              exit(0);
            });
      }

      if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();
        if ((locationPermission != LocationPermission.whileInUse) &&
            (locationPermission != LocationPermission.always)) {
          MyDialog(context: context).normalActionDilalog(
              title: 'ปิดกันการแชร์ต่ำแหน่ง อยู่',
              message: 'กรุณาเปิด ด้วยคะ',
              label: 'ไปเปิด การแชร์ต่ำแหน่ง',
              pressFunc: () {
                Geolocator.openAppSettings();
                exit(0);
              });
        }
      } else {
        var location = await Geolocator.getCurrentPosition();
        lat = location.latitude;
        lng = location.longitude;
        print('lat ===> $lat, lng ===> $lng');

        MarkerId markerId = const MarkerId('id');
        Marker marker = Marker(
            markerId: markerId,
            position: LatLng(lat!, lng!),
            infoWindow:
                InfoWindow(title: 'คุณอยู่ที่นี่', snippet: '($lat, $lng)'));
        markers[markerId] = marker;

        setState(() {});
      }
    } else {
      MyDialog(context: context).normalActionDilalog(
          title: 'ปิด Location อยู่',
          message: 'กรุณาเปิด Location Service ด้วยคะ',
          label: 'ไปเปิด Location Service',
          pressFunc: () {
            Geolocator.openLocationSettings();
            exit(0);
          });
    }
  }
}
