// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
import 'dart:io';
import 'dart:math';

import 'package:admanyout/models/category_room_model.dart';
import 'package:admanyout/models/fast_group_model.dart';
import 'package:admanyout/models/fast_link_model.dart';
import 'package:admanyout/models/link_model.dart';
import 'package:admanyout/models/room_model.dart';
import 'package:admanyout/models/song_model.dart';
import 'package:admanyout/models/user_model.dart';
import 'package:admanyout/states/add_product.dart';
import 'package:admanyout/states2/grand_home.dart';
import 'package:admanyout/utility/my_constant.dart';
import 'package:admanyout/utility/my_dialog.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/utility/my_process.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/shop_progress.dart';
import 'package:admanyout/widgets/show_button.dart';
import 'package:admanyout/widgets/show_form.dart';
import 'package:admanyout/widgets/show_form_long.dart';
import 'package:admanyout/widgets/show_icon_button.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:admanyout/widgets/show_text_button.dart';
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

  TextEditingController linkContactController = TextEditingController();

  File? productFile;
  String? urlProduct;

  bool showDetailBool = false;

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
      backgroundColor: MyStyle.bgColor,
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
                    ShowTextButton(
                      label: showDetailBool ? 'Hint Detail' : 'Show Detail',
                      pressFunc: () {
                        setState(() {
                          showDetailBool = !showDetailBool;
                        });
                      },
                      textStyle: MyStyle().h3RedStyle(),
                    ),
                    showDetailBool
                        ? contentForm(boxConstraints)
                        : const SizedBox(),
                    productFile == null
                        ? const SizedBox()
                        : Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            width: 180,
                            height: 150,
                            child: Image.file(productFile!),
                          ),
                    newGroup(boxConstraints: boxConstraints),
                  ],
                ),
              );
            }),
    );
  }

  Widget contentForm(BoxConstraints boxConstraints) {
    return Column(
      children: [
        formDetail(
          boxConstraints: boxConstraints,
          label: 'Link คลิกหน้าจอ',
          changeFunc: (p0) {
            addLink = p0.trim();
          },
        ),
        formDetail(
          textEditingController: linkContactController,
          boxConstraints: boxConstraints,
          label: 'Link ติดต่อ',
          changeFunc: (p0) {
            linkContact = p0.trim();
          },
          iconData: Icons.more_vert,
          iconPressFunc: () {
            dialogListLinkContact();
          },
        ),
        formDetail(
          boxConstraints: boxConstraints,
          label: 'ชื่อสินค้า',
          changeFunc: (p0) {
            head = p0.trim();
          },
          iconData: Icons.image,
          iconPressFunc: () async {
            var result =
                await MyProcess().processTakePhoto(source: ImageSource.gallery);
            if (result != null) {
              productFile = File(result.path);
              setState(() {});
            }
          },
        ),
      ],
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
        label: 'Post',
        pressFunc: () async {
          if (detail?.isEmpty ?? true) {
            detail = '';
          }

          if (productFile != null) {
            String nameFileProduct = 'product${Random().nextInt(1000000)}.jpg';
            FirebaseStorage storage = FirebaseStorage.instance;
            Reference reference =
                storage.ref().child('product/$nameFileProduct');
            UploadTask task = reference.putFile(productFile!);
            await task.whenComplete(() async {
              await reference.getDownloadURL().then((value) {
                urlProduct = value;
              });
            });
          }

          await processFindLocation().then((value) async {
            DateTime dateTime = DateTime.now();

            print('##23seb lat = $lat, lng = $lng, dateTime ==> $dateTime');

            File file;
            var result =
                await MyProcess().processTakePhoto(source: ImageSource.camera);
            if (result != null) {
              file = File(result.path);

              String nameFile = 'image${Random().nextInt(1000000)}.jpg';
              FirebaseStorage storage = FirebaseStorage.instance;
              Reference reference = storage.ref().child('photofast2/$nameFile');
              UploadTask uploadTask = reference.putFile(file);
              await uploadTask.whenComplete(() async {
                await reference.getDownloadURL().then((value) {
                  String urlImage2 = value;
                  print('##23seb ==> $urlImage2');
                  processUploadAndInsertFastLink(urlImage2: urlImage2);
                });
              });
            }
          });
        },
      ),
    );
  }

  Future<void> processUploadAndInsertFastLink(
      {required String urlImage2}) async {
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
          keyRoom: chooseRoomModel?.keyRoom ?? '',
          linkContact: linkContactController.text,
          nameButtonLinkContact: nameButtonLinkContact ?? '',
          position: position,
          urlImage2: urlImage2,
          urlProduct: urlProduct ?? '',
          discovery: true,
          friendOnly: false,
        );

        print('fastLinkModel ==> ${fastLinkModel.toMap()}');

        await FirebaseFirestore.instance
            .collection('fastlink')
            .doc()
            .set(fastLinkModel.toMap())
            .then((value) async {
          //process Sent Noti
          await MyFirebase().sentNoti();

          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const GrandHome(),
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
    TextEditingController? textEditingController,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      // height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            width: boxConstraints.maxWidth * 0.65,
            child: ShowFormLong(
              textEditingController: textEditingController,
              marginTop: 0,
              label: label,
              changeFunc: changeFunc,
              iconDataSubfix: iconData,
              pressFunc: iconPressFunc,
            ),
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
      mainAxisAlignment: MainAxisAlignment.center,
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
                  builder: (context) => const GrandHome(),
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

  Future<void> dialogListLinkContact() async {
    var linkModels = <LinkModel>[];
    String? linkUrl, nameLink;

    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .collection('link')
        .get()
        .then((value) {
      for (var element in value.docs) {
        LinkModel linkModel = LinkModel.fromMap(element.data());
        linkModels.add(linkModel);
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                linkModels.isEmpty
                    ? const SizedBox()
                    : Container(
                        width: 200, height: 200,
                        // constraints: const BoxConstraints(
                        //   minWidth: 100,
                        //   minHeight: 100,
                        //   maxWidth: 200,
                        //   maxHeight: 200,
                        // ),
                        child: ListView.builder(
                          physics: const ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: linkModels.length,
                          itemBuilder: (context, index) => InkWell(
                            onTap: () {
                              print('index ==> $index');
                              linkContactController.text =
                                  linkModels[index].urlLink;
                              setState(() {});
                              Navigator.pop(context);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShowText(
                                  label: linkModels[index].nameLink,
                                  textStyle: MyStyle().h2Style(),
                                ),
                                ShowText(
                                  label: linkModels[index].urlLink,
                                  textStyle: MyStyle().h3Style(),
                                ),
                                Divider(
                                  color: MyStyle.dark,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ShowText(
                    label: 'เพิ่ม Link',
                    textStyle: MyStyle().h2Style(),
                  ),
                ),
                ShowFormLong(
                  label: 'Link Url',
                  changeFunc: (p0) {
                    linkUrl = p0.trim();
                  },
                ),
                ShowFormLong(
                  label: 'Name Link',
                  changeFunc: (p0) {
                    nameLink = p0.trim();
                  },
                ),
              ],
            ),
          ),
          actions: [
            ShowTextButton(
              textStyle: MyStyle().h3GreenStyle(),
              label: 'เพิ่ม Link ใหม่',
              pressFunc: () async {
                print('###### linkUrl ==> $linkUrl, nameLink = $nameLink');
                if ((linkUrl?.isNotEmpty ?? false) &&
                    (nameLink?.isNotEmpty ?? false)) {
                  LinkModel linkModel = LinkModel(
                      nameLink: nameLink!, urlLink: linkUrl!, groupLink: '');

                  await MyFirebase()
                      .addNewLinkToUser(
                          uidUser: user!.uid, linkModel: linkModel)
                      .then((value) {
                    linkContactController.text = linkUrl!;
                    setState(() {});
                  });
                }
                Navigator.pop(context);
              },
            ),
            ShowTextButton(
              textStyle: MyStyle().h3RedStyle(),
              label: 'Cancel',
              pressFunc: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      );
    });
  }
}
