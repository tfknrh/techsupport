import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:techsupport/controllers/c_category.dart';
import 'package:techsupport/controllers/c_aktivitas.dart';
//import 'package:techsupport/controllers/c_aktivitas.dart';
import 'package:techsupport/utils/u_color.dart';
import 'package:techsupport/widgets/w_customSwitch.dart';
import 'package:techsupport/widgets/w_text.dart';
import 'package:techsupport/models/m_setting.dart';
import 'package:theme_mode_handler/theme_mode_handler.dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:techsupport/api/a_db.dart';
import 'dart:io' as io;
import 'package:ext_storage/ext_storage.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;

  final http.Client _client = new http.Client();

  GoogleAuthClient(this._headers);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Color _tempShadeColor = Colors.blueAccent[100];
  Color _shadeColor = Colors.blue[800];
  List<Setting> _listSetting = [];
  Setting sys;

  bool ready = false;
  String fileId;
  Future<void> getSetting() async {
    _listSetting = await DataBaseMain.db.getListSys();
    ready = true;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getSetting();
  }

  Future<void> deletefromGdrive() async {
    //  _listSetting.clear();
    //  getSetting();

    final googleSignIn =
        signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    final signIn.GoogleSignInAccount account = await googleSignIn.signIn();
    print("User account $account");

    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    await driveApi.files.delete(_listSetting.first.sysDBId);
  }

  Future<void> uploadtoGdrive() async {
    // deletefromGdrive();
    final googleSignIn =
        signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    final signIn.GoogleSignInAccount account = await googleSignIn.signIn();
    print("User account $account");

    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    var dir = await ExtStorage.getExternalStorageDirectory();
    final filename = "techsupport.db";
    var driveFile = new drive.File();
    driveFile.name = filename;
    final localFile = io.File("$dir/techsupport/techsupport.db");
    await driveApi.files.delete(_listSetting.first.sysDBId);
    final result = await driveApi.files.create(driveFile,
        uploadMedia: drive.Media(localFile.openRead(), localFile.lengthSync()));

    await DataBaseMain.db.updateSys("sysGmail", account.email);
    await DataBaseMain.db.updateSys("sysDBId", result.id);
    await DataBaseMain.db.updateSys("sysBackupSize", result.size);
    await DataBaseMain.db
        .updateSys("sysModified", result.modifiedTime.toString());
    await DataBaseMain.db.updateSys("sysCreated",
        DateFormat("dd-MM-yyyy HH:mm:ss").format(DateTime.now()).toString());

    getSetting();
// if (result == "success") {
//                       Navigator.pop(context);
//                       await Provider.of<AktivitasProvider>(context,
//                               listen: false)
//                           .initData();
//                     } else {
//                       SnackBars.showErrorSnackBar(myScaContext, context,
//                           Icons.error, "Customer", x.message);
//
  }

  int _intTable;
  var valTable = <String>["Aktivitas", "Customer", "Images"];
  String strTable;

  void _openDialog(String title, Widget content) {
    showDialog(
      context: context,
      builder: (_) {
        return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              contentPadding: const EdgeInsets.all(6.0),
              backgroundColor: MColors.dialogsColor(context),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text(title),
              content: content,
              actions: [
                ElevatedButton(
                  child: Text('Batal'),
                  onPressed: Navigator.of(context).pop,
                ),
                ElevatedButton(
                  child: Text('Iya'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() => MColors.main = _tempShadeColor);
                    Provider.of<AktivitasProvider>(context, listen: false)
                        .update();
                    Provider.of<AktivitasProvider>(context, listen: false)
                        .update();
                    Provider.of<CategoryProvider>(context, listen: false)
                        .update();
                  },
                ),
              ],
            ));
      },
    );
  }

  static const themeModeOptions = [
    {'label': 'Sistem', 'value': ThemeMode.system, 'icon': Icons.settings},
    {'label': 'Cerah', 'value': ThemeMode.light, 'icon': Icons.wb_sunny},
    {
      'label': 'Gelap',
      'value': ThemeMode.dark,
      'icon': MaterialCommunityIcons.moon_full
    },
  ];
  static void _selectThemeMode(BuildContext context, ThemeMode value) async {
    ThemeModeHandler.of(context).saveThemeMode(value);
    Navigator.pop(context, value);
  }

  static Future<ThemeMode> showThemePickerDialog(
      {@required BuildContext contexts}) {
    return showDialog(
        context: contexts,
        builder: (context) {
          return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: SimpleDialog(
                backgroundColor: MColors.dialogsColor(context),
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                title: Text('Pilih Tema',
                    style: CText.primarycustomText(2, context, 'RobotoMedium')),
                children: themeModeOptions.map((option) {
                  return SimpleDialogOption(
                    onPressed: () =>
                        _selectThemeMode(contexts, option['value']),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(option['icon'],
                              color: Theme.of(context).accentColor),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            option['label'],
                            style: CText.primarycustomText(
                                1.8, context, 'RobotoMedium'),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Consumer<AktivitasProvider>(builder: (context, value, child) {
      return Scaffold(
        backgroundColor: MColors.backgroundColor(context),
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          backgroundColor: MColors.backgroundColor(context),
          elevation: 0,
          title: Text(
            "Setting",
            style: CText.primarycustomText(2.5, context, "CircularStdBold"),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _size.width * .05),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    Provider.of<AktivitasProvider>(context, listen: false)
                        .notificationManager
                        .showNotification(true
                            // value.sharedPrepeferencesGetValueIsAlarm()
                            );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Icon(
                          AntDesign.notification,
                          color: MColors.buttonColor(),
                        ),
                        SizedBox(
                          width: _size.width * .02,
                        ),
                        Expanded(
                          child: Text(
                            "Push Notificacion",
                            style: CText.primarycustomText(
                                1.7, context, 'CircularStdBook'),
                          ),
                        ),
                        SizedBox(
                          width: _size.width * 0.04,
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: Theme.of(context).iconTheme.color,
                        )
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: MColors.secondaryTextColor(context),
                ),
                InkWell(
                  onTap: () {
                    _openDialog(
                      "Select Color",
                      MaterialColorPicker(
                        shrinkWrap: true,
                        selectedColor: _shadeColor,
                        onColorChange: (color) =>
                            setState(() => _tempShadeColor = color),
                        onBack: () => print("Back button pressed"),
                      ),
                    );
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.colorize,
                          color: MColors.buttonColor(),
                        ),
                        SizedBox(
                          width: _size.width * .02,
                        ),
                        Expanded(
                          child: Text(
                            "Color",
                            style: CText.primarycustomText(
                                1.7, context, 'CircularStdBook'),
                          ),
                        ),
                        SizedBox(
                          width: _size.width * 0.04,
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: Theme.of(context).iconTheme.color,
                        )
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: MColors.secondaryTextColor(context),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    showThemePickerDialog(contexts: this.context);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Icon(
                          MaterialCommunityIcons.theme_light_dark,
                          color: MColors.buttonColor(),
                        ),
                        SizedBox(
                          width: _size.width * .02,
                        ),
                        Expanded(
                          child: Text(
                            "Ganti Tema",
                            style: CText.primarycustomText(
                                1.7, context, 'CircularStdBook'),
                          ),
                        ),
                        SizedBox(
                          width: _size.width * 0.04,
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: Theme.of(context).iconTheme.color,
                        )
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: MColors.secondaryTextColor(context),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings_backup_restore,
                          color: MColors.buttonColor(),
                        ),
                        SizedBox(
                          width: _size.width * .02,
                        ),
                        Expanded(
                          child: Text(
                            "Backup to local",
                            style: CText.primarycustomText(
                                1.7, context, 'CircularStdBook'),
                          ),
                        ),
                        SizedBox(
                          width: _size.width * 0.04,
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: Theme.of(context).iconTheme.color,
                        )
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: MColors.secondaryTextColor(context),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    uploadtoGdrive();
                    showDialog(
                        context: context,
                        builder: (_) {
                          return BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: AlertDialog(
                                  contentPadding: const EdgeInsets.all(6.0),
                                  backgroundColor:
                                      MColors.dialogsColor(context),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  title: Text("Setting"),
                                  content: Text("Backup ke google berhasil"),
                                  actions: [
                                    ElevatedButton(
                                      child: Text('Ok'),
                                      onPressed: Navigator.of(context).pop,
                                    )
                                  ]));
                        });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Icon(
                          AntDesign.google,
                          color: MColors.buttonColor(),
                        ),
                        SizedBox(
                          width: _size.width * .02,
                        ),
                        Expanded(
                          child: Text(
                            "Backup to Google Drive",
                            style: CText.primarycustomText(
                                1.7, context, 'CircularStdBook'),
                          ),
                        ),
                        SizedBox(
                          width: _size.width * 0.04,
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: Theme.of(context).iconTheme.color,
                        )
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: MColors.secondaryTextColor(context),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: MColors.buttonColor(),
                      ),
                      SizedBox(
                        width: _size.width * .02,
                      ),
                      Expanded(
                        child: Text(
                          "Allow Time Schedule",
                          style: CText.primarycustomText(
                              1.7, context, 'CircularStdBook'),
                        ),
                      ),
                      FlutterSwitch(
                        width: _size.width * 0.12,
                        height: 25.0,
                        toggleSize: _size.width * 0.04,
                        value:
                            true, //value.sharedPrepeferencesGetValueIsNotif(),
                        borderRadius: 30.0,
                        activeColor: MColors.buttonColor(),
                        inactiveColor:
                            MColors.secondaryBackgroundColor(context),
                        padding: _size.width * 0.01,
                        showOnOff: false,
                        onToggle: (val) {
                          // value.setNotifValue(val);
                        },
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: MColors.secondaryTextColor(context),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.alarm,
                        color: MColors.buttonColor(),
                      ),
                      SizedBox(
                        width: _size.width * .02,
                      ),
                      Expanded(
                        child: Text(
                          "Notification Alarm",
                          style: CText.primarycustomText(
                              1.7, context, 'CircularStdBook'),
                        ),
                      ),
                      FlutterSwitch(
                        width: _size.width * 0.12,
                        height: 25.0,
                        toggleSize: _size.width * 0.04,
                        value:
                            true, //value.sharedPrepeferencesGetValueIsAlarm(),
                        borderRadius: 30.0,
                        inactiveColor:
                            MColors.secondaryBackgroundColor(context),
                        activeColor: MColors.buttonColor(),
                        padding: _size.width * 0.01,
                        showOnOff: false,
                        onToggle: (val) {
                          //value.setNotifValueIsAlarm(val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
