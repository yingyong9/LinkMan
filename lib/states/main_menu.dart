import 'package:admanyout/states/add_product.dart';
import 'package:admanyout/utility/my_firebase.dart';
import 'package:admanyout/utility/my_style.dart';
import 'package:admanyout/widgets/show_text.dart';
import 'package:admanyout/widgets/show_text_button.dart';
import 'package:admanyout/widgets/widget_listtile.dart';
import 'package:flutter/material.dart';

import 'base_manage_my_link.dart';
import 'edit_profile.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyStyle.dark,
      appBar: newAppBar(),
      body: Stack(
        children: [
          ListView(
            children: [
              WidgetListtile(
                contentColor: MyStyle.bgColor,
                leadIcon: Icons.check_circle,
                title: 'Version 1.0.40',
                pressFunc: () {},
              ),
              Divider(
                color: MyStyle.bgColor,
              ),
              WidgetListtile(
                contentColor: MyStyle.bgColor,
                leadIcon: Icons.person,
                title: 'Profile',
                pressFunc: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfile(),
                      ));
                },
                telingIcon: Icons.forward,
              ),
              Divider(
                color: MyStyle.bgColor,
              ),
              WidgetListtile(
                contentColor: MyStyle.bgColor,
                leadIcon: Icons.group,
                title: 'Contact Link',
                pressFunc: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BaseManageMyLink(),
                      )).then((value) {
                    print('pop from BaseMenageLink');
                  });
                },
                telingIcon: Icons.forward,
              ),
              Divider(
                color: MyStyle.bgColor,
              ),
              WidgetListtile(
                contentColor: MyStyle.bgColor,
                leadIcon: Icons.precision_manufacturing,
                title: 'Product',
                pressFunc: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddProduct(),
                      ));
                },
                telingIcon: Icons.forward,
              ),
              Divider(
                color: MyStyle.bgColor,
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(
                    color: MyStyle.bgColor,
                  ),
                  ShowTextButton(
                    label: 'SignOut',
                    pressFunc: () async {
                      MyFirebase().processSignOut(context: context);
                    },
                    textStyle: MyStyle().h2Style(color: MyStyle.bgColor),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  AppBar newAppBar() {
    return AppBar(
      centerTitle: true,
      title: ShowText(
        label: 'Setting',
        textStyle: MyStyle().h2Style(color: MyStyle.bgColor),
      ),
      foregroundColor: MyStyle.bgColor,
      backgroundColor: MyStyle.dark,
    );
  }
}
