import 'package:flashy_tab_bar/flashy_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:techsupport/api/a_db.dart';
import 'package:techsupport/controllers.dart';
import 'package:techsupport/widgets.dart';
import 'package:techsupport/utils.dart';
import 'package:techsupport/screens.dart';
import 'package:techsupport/models.dart';
import 'package:permissions_plugin/permissions_plugin.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:move_to_background/move_to_background.dart';

import 'package:theme_mode_handler/theme_mode_handler.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'dart:io';
import 'package:ext_storage/ext_storage.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> checkPermissions(BuildContext context) async {
    // final PermissionState aks =
    //     await PermissionsPlugin.isIgnoreBatteryOptimization;

    // PermissionState resBattery;
    // if (aks != PermissionState.GRANTED)
    //   resBattery = await PermissionsPlugin.requestIgnoreBatteryOptimization;

    // print(resBattery);

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
        print("permission ok");
      else
        permissionsDenied(context);
    } else {
      print("permission ok");
    }
  }

  void permissionsDenied(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext _context) {
          return SimpleDialog(
            title: const Text("Izin ditolak"),
            children: <Widget>[
              Container(
                padding:
                    EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
                child: const Text(
                  "Anda harus memberikan semua izin untuk menggunakan aplikasi ini",
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              )
            ],
          );
        });
  }

  getSetting() async {
    List<Setting> list = await DataBaseMain.getListSettings();
    ThemeModeHandler.of(context).saveThemeMode(
        list.first.sysTheme == "dark" ? ThemeMode.dark : ThemeMode.light);
    MColors.main =
        list.first.sysColor == null ? Colors.blue[100] : list.first.sysColor;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    checkPermissions(context);
    downloadGdrive();
    getSetting();
    Provider.of<CustomerProvider>(context, listen: false).getListCustomers();
    Provider.of<CategoryProvider>(context, listen: false).getListCategorys();
    Provider.of<FormulirProvider>(context, listen: false).getListFormulirs();
    Provider.of<ImagesProvider>(context, listen: false).getListImagess();
    Provider.of<SettingProvider>(context, listen: false).getListSettings();
    Provider.of<AktivitasProvider>(context, listen: false).initData();
    //Provider.of<ListData>(context, listen: false);

    TimerLoop(
        duration: Duration(seconds: 30),
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
  Future<void> downloadGdrive() async {
    var dir = await ExtStorage.getExternalStorageDirectory();
    if (!File("$dir/techsupport/gdrive").existsSync()) {
      final googleSignIn =
          signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
      final signIn.GoogleSignInAccount account = await googleSignIn.signIn();
      //print("User account $account");

      final authHeaders = await account.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);
      final list = await driveApi.files.list(q: "name = 'techsupport.db'");
      print(list.toJson().toString());
      drive.Media file = await driveApi.files.get(list.files[0].id,
          downloadOptions: drive.DownloadOptions.fullMedia);
      print(file.stream);

      var pathDB = "$dir/techsupport";
      var pathImage = "$pathDB/images";

      if (!Directory(pathDB).existsSync()) {
        Directory(pathDB).createSync(recursive: true);
      }
      if (!File("$pathDB/techsupport.db").existsSync()) {
        final saveFile = File("$pathDB/" + list.files[0].name);
        List<int> dataStore = [];
        file.stream.listen((data) {
          //  print("DataReceived: ${data.length}");
          dataStore.insertAll(dataStore.length, data);
        }, onDone: () {
          print("Task Done");
          saveFile.writeAsBytes(dataStore);
          print("File saved at ${saveFile.path}");
        }, onError: (error) {
          print(error);
        });
      }

      final img = await driveApi.files.list(q: "name contains 'IMG'");
      print(img.toJson().toString());
      if (!Directory(pathImage).existsSync()) {
        Directory(pathImage).createSync(recursive: true);
      }
      if (img.files.length > 0) {
        for (int i = 0; i < img.files.length; i++) {
          drive.Media fileImg = await driveApi.files.get(img.files[i].id,
              downloadOptions: drive.DownloadOptions.fullMedia);
          if (!File("$pathImage/" + img.files[i].name).existsSync()) {
            final saveFileImg = new File("$pathImage/" + img.files[i].name);
            List<int> dataImage = [];
            fileImg.stream.listen((dataImg) {
              //   print("DataReceived: ${dataImg.length}");
              dataImage.insertAll(dataImage.length, dataImg);
            }, onDone: () {
              print("Task Done");
              saveFileImg.writeAsBytes(dataImage);
              print("File saved at ${saveFileImg.path}");
            }, onError: (error) {
              print(error);
            });
          }
        }
      }

      File("$dir/techsupport/gdrive").createSync(recursive: true);
    }
    // final directory = await getExternalStorageDirectory();
  }

  @override
  Widget build(BuildContext context) {
    final _responsive = Responsive(context);
    return WillPopScope(onWillPop: () async {
      MoveToBackground.moveTaskToBack();
      return false;
    }, child: Consumer<AktivitasProvider>(builder: (context, value, _) {
      return Scaffold(
        backgroundColor: MColors.backgroundColor(context),
        body: _children[value.selectedIndex],
        bottomNavigationBar:
            // FlashyTabBar(
            //   animationCurve: Curves.easeIn,
            //   height: 70,
            //   animationDuration: Duration(milliseconds: 300),
            //   selectedIndex: value.selectedIndex,
            //   backgroundColor: MColors.dialogsColor(context),
            //   iconSize: _responsive.ip(2.3),
            //   showElevation: true,
            //   onItemSelected: (index) => value.setTabBarIndex(index),
            //   items: [

            //     FlashyTabBarItem(
            //       activeColor: MColors.buttonColor(),
            //       inactiveColor: MColors.textColor(context).withOpacity(0.7),
            //       icon: Icon(AntDesign.calendar),
            //       title: Text('Aktivitas',
            //           style: TextStyle(fontFamily: 'CircularStdBold')),
            //     ),
            //     FlashyTabBarItem(
            //       activeColor: MColors.buttonColor(),
            //       inactiveColor: MColors.textColor(context).withOpacity(0.7),
            //       icon: Icon(Icons.person),
            //       title: Text('Customer',
            //           style: TextStyle(fontFamily: 'CircularStdBold')),
            //     ),
            //     FlashyTabBarItem(
            //       activeColor: MColors.buttonColor(),
            //       inactiveColor: MColors.textColor(context).withOpacity(0.7),
            //       icon: Icon(AntDesign.setting),
            //       title: Text('Setting',
            //           style: TextStyle(fontFamily: 'CircularStdBold')),
            //     ),
            //   ],
            // )
            BottomNavigationBar(
          backgroundColor: MColors.dialogsColor(context),
          currentIndex: value.selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 10,
          selectedLabelStyle: TextStyle(color: MColors.buttonColor()),
          selectedItemColor: MColors.buttonColor(),
          unselectedFontSize: 10,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                margin: EdgeInsets.only(bottom: 5),
                child: Icon(
                  AntDesign.calendar,
                  color: (value.selectedIndex == 0)
                      ? MColors.buttonColor()
                      : MColors.textColor(context).withOpacity(0.7),
                ),
              ),
              label: 'Aktivitas',
            ),
            BottomNavigationBarItem(
              icon: Container(
                margin: EdgeInsets.only(bottom: 5),
                child: Icon(
                  AntDesign.user,
                  color: (value.selectedIndex == 1)
                      ? MColors.buttonColor()
                      : MColors.textColor(context).withOpacity(0.7),
                ),
              ),
              label: 'Customer',
            ),
            BottomNavigationBarItem(
              icon: Container(
                margin: EdgeInsets.only(bottom: 5),
                child: Icon(
                  AntDesign.setting,
                  color: (value.selectedIndex == 2)
                      ? MColors.buttonColor()
                      : MColors.textColor(context).withOpacity(0.7),
                ),
              ),
              label: 'Setting',
            ),
          ],
          onTap: (index) {
            setState(() {
              value.selectedIndex = index;
            });
          },
        ),
      );
    }));
  }
}
