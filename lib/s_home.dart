import 'package:flashy_tab_bar/flashy_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:techsupport/controllers/c_category.dart';
import 'package:techsupport/controllers/c_customer.dart';
import 'package:techsupport/controllers/c_aktivitas.dart';
import 'package:techsupport/controllers/c_setting.dart';
import 'package:techsupport/screens/customer/s_customer.dart';
import 'package:techsupport/widgets/w_timer.dart';
import 'package:techsupport/screens/aktivitas/s_aktivitas.dart';
import 'package:techsupport/screens/settings/s_settings.dart';
import 'package:techsupport/utils/u_color.dart';

import 'package:techsupport/utils/u_time.dart';
import 'package:techsupport/utils/u_responsive.dart';

import 'package:permissions_plugin/permissions_plugin.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:move_to_background/move_to_background.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> checkPermissions(BuildContext context) async {
    final PermissionState aks =
        await PermissionsPlugin.isIgnoreBatteryOptimization;

    PermissionState resBattery;
    if (aks != PermissionState.GRANTED)
      resBattery = await PermissionsPlugin.requestIgnoreBatteryOptimization;

    print(resBattery);

    Map<Permission, PermissionState> permission =
        await PermissionsPlugin.checkPermissions([
      Permission.ACCESS_FINE_LOCATION,
      Permission.WRITE_EXTERNAL_STORAGE,
      Permission.READ_EXTERNAL_STORAGE,

      // Permission.ACCESS_COARSE_LOCATION,
      //  Permission.READ_PHONE_STATE
    ]);

    if (permission[Permission.ACCESS_FINE_LOCATION] !=
                PermissionState.GRANTED ||
            permission[Permission.WRITE_EXTERNAL_STORAGE] !=
                PermissionState.GRANTED ||
            permission[Permission.READ_EXTERNAL_STORAGE] !=
                PermissionState.GRANTED
        //   permission[Permission.READ_PHONE_STATE] !=
        //  PermissionState.GRANTED
        ) {
      try {
        permission = await PermissionsPlugin.requestPermissions([
          Permission.ACCESS_FINE_LOCATION,
          Permission.WRITE_EXTERNAL_STORAGE,
          Permission.READ_EXTERNAL_STORAGE,
          //   Permission.READ_PHONE_STATE
        ]);
      } on Exception {
        debugPrint("Error");
      }

      if (permission[Permission.ACCESS_FINE_LOCATION] ==
                  PermissionState.GRANTED &&
              permission[Permission.WRITE_EXTERNAL_STORAGE] ==
                  PermissionState.GRANTED &&
              permission[Permission.READ_EXTERNAL_STORAGE] ==
                  PermissionState.GRANTED
          //  permission[Permission.READ_PHONE_STATE] ==
          //  PermissionState.GRANTED
          )
        print("Login ok");
      else
        permissionsDenied(context);
    } else {
      print("Login ok");
    }
  }

  void permissionsDenied(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext _context) {
          return SimpleDialog(
            title: const Text("Permisos denegados"),
            children: <Widget>[
              Container(
                padding:
                    EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
                child: const Text(
                  "Debes conceder todo los permiso para poder usar esta aplicacion",
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              )
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    Provider.of<CustomerProvider>(context, listen: false).getListCustomers();
    Provider.of<CategoryProvider>(context, listen: false).getListCategorys();
    Provider.of<AktivitasProvider>(context, listen: false).initData();
    Provider.of<SettingProvider>(context, listen: false).initData();
    TimerLoop(
        duration: Duration(seconds: 5),
        onTick: () {
          if (TimeValidator.getDatenTimeSch(
                  Provider.of<SettingProvider>(context, listen: false)
                      .setting
                      .first
                      .sysBackupSch) ==
              TimeValidator.getDatenTimeSch(DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  DateTime.now().hour,
                  DateTime.now().minute))) {
            Provider.of<SettingProvider>(context, listen: false)
                .uploadtoGdriveSch();
          }
        });
  }

  final List<Widget> _children = [
    //RutinaScreen(),
    AktivitassScreen(),
    CustomersScreen(),
    SettingsScreen(),
  ];
  var _androidAppRetain = MethodChannel("android_app_retain");

  @override
  Widget build(BuildContext context) {
    checkPermissions(context);
    final _responsive = Responsive(context);
    return WillPopScope(onWillPop: () async {
      MoveToBackground.moveTaskToBack();
      return false;
    }, child: Consumer<AktivitasProvider>(builder: (context, value, _) {
      return Scaffold(
          backgroundColor: MColors.backgroundColor(context),
          body: _children[value.selectedIndex],
          bottomNavigationBar: FlashyTabBar(
            animationCurve: Curves.easeIn,
            height: 70,
            animationDuration: Duration(milliseconds: 300),
            selectedIndex: value.selectedIndex,
            backgroundColor: MColors.dialogsColor(context),
            iconSize: _responsive.ip(2.3),
            showElevation: true,
            onItemSelected: (index) => value.setTabBarIndex(index),
            items: [
              // FlashyTabBarItem(
              //   activeColor: MColors.buttonColor(),
              //   inactiveColor: MColors.textColor(context).withOpacity(0.7),
              //   icon: Icon(AntDesign.home),
              //   title: Text('Aktivitas',
              //       style: TextStyle(fontFamily: 'CircularStdBold')),
              // ),
              FlashyTabBarItem(
                activeColor: MColors.buttonColor(),
                inactiveColor: MColors.textColor(context).withOpacity(0.7),
                icon: Icon(AntDesign.calendar),
                title: Text('Aktivitas',
                    style: TextStyle(fontFamily: 'CircularStdBold')),
              ),
              FlashyTabBarItem(
                activeColor: MColors.buttonColor(),
                inactiveColor: MColors.textColor(context).withOpacity(0.7),
                icon: Icon(Icons.person),
                title: Text('Customer',
                    style: TextStyle(fontFamily: 'CircularStdBold')),
              ),
              FlashyTabBarItem(
                activeColor: MColors.buttonColor(),
                inactiveColor: MColors.textColor(context).withOpacity(0.7),
                icon: Icon(AntDesign.setting),
                title: Text('Setting',
                    style: TextStyle(fontFamily: 'CircularStdBold')),
              ),
            ],
          ));
    }));
  }
}
