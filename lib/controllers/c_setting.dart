import 'package:flutter/widgets.dart';
import 'package:techsupport/api/a_db.dart';
import 'package:techsupport/api/a_response.dart';
import 'package:techsupport/models/m_setting.dart';
import 'package:techsupport/models/m_customer.dart';

import 'package:techsupport/utils/u_notification.dart';
import 'package:techsupport/utils/u_time.dart';
import 'package:flutter/material.dart';

import 'package:techsupport/utils/u_color.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import 'package:techsupport/widgets/w_timer.dart';
import 'package:http/http.dart' as http;

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;

import 'dart:io' as io;
import 'package:ext_storage/ext_storage.dart';
import 'package:techsupport/utils/u_filesize.dart';
import 'dart:async';
import 'dart:math';

//import 'package:shared_preferences/shared_preferences.dart';
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;

  final http.Client _client = new http.Client();

  GoogleAuthClient(this._headers);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class SettingProvider with ChangeNotifier {
  NotificationManager notificationManager = NotificationManager();
  List<Setting> setting = [];
  List<ItemSetting> itemSetting = [];
  String languageCode;

  int selectedIndex = 0;
  TimeOfDay timeSelected = TimeOfDay.now();

//  SharedPreferences sharedPreferences;
  void getListSettings() async {
    final x = await DataBaseMain.db.getListSettings();
    setting = x;
    notifyListeners();
  }

  Future<void> initData() async {
    setting.clear();
    setting = await DataBaseMain.db.getListSettings();
    itemSetting.clear();
    itemSetting = [
      ItemSetting(
        title: "Backup",
        group: "Backup ke GDrive",
        subtitle: "",
        tipe: 2,
      ),
      ItemSetting(
        group: "Tampilan",
        title: "Tema",
        subtitle: "",
        tipe: 1,
      ),
      ItemSetting(
        group: "Tampilan",
        title: "Color",
        subtitle: "",
        tipe: 1,
      ),
      ItemSetting(
        group: "Backup ke GDrive",
        title: "Schedule",
        subtitle: DateFormat("HH:mm").format(setting.first.sysBackupSch),
        tipe: 1,
      ),
      ItemSetting(
        group: "Backup ke GDrive",
        title: "Terakhir Backup",
        subtitle: DateFormat("dd MMMM yyyy HH:mm:ss")
            .format(setting.first.sysCreated)
            .toString(),
        tipe: 1,
      ),
      ItemSetting(
          group: "Backup ke GDrive",
          title: "Ukuran File",
          subtitle: filesize(setting.first.sysBackupSize),
          tipe: 1),
      ItemSetting(
        group: "Backup ke GDrive",
        title: "Akun",
        subtitle: setting.first.sysGmail,
        tipe: 1,
      ),
    ];
    // Timer.periodic(
    //     Duration(seconds: 5),
    //     (Timer t) =>
    //         setting.first.sysBackupSch = TimeOfDay.now() ?? uploadtoGdrive());

    notifyListeners();
  }

  setTabBarIndex(int i) {
    selectedIndex = i;
    notifyListeners();
  }

  void update() {
    notifyListeners();
  }

  // bool sharedPrepeferencesGetValueIsNotif() {
  //   final x = sharedPreferences.getBool("izinNotif");
  //   return x == null ? false : x;
  // }

  // void setNotifValue(bool e) {
  //   sharedPreferences.setBool("izinNotif", e);
  //   notifyListeners();
  // }

  // bool sharedPrepeferencesGetValueIsAlarm() {
  //   final x = sharedPreferences.getBool("isAlarm");
  //   return x == null ? false : x;
  // }

  // void setNotifValueIsAlarm(bool e) {
  //   sharedPreferences.setBool("isAlarm", e);
  //   notifyListeners();
  // }

  Future<Response> addSetting(
      int sysCountAkt,
      int sysCountCust,
      int sysCountImg,
      String sysBackupSize,
      DateTime sysBackupSch,
      String sysGmail,
      String sysDBId,
      DateTime sysCreated,
      DateTime sysModified) async {
    Response r = Response();
    Setting e = Setting();
    e.sysCountAkt = sysCountAkt;
    e.sysCountCust = sysCountCust;
    e.sysCountImg = sysCountImg;

    e.sysBackupSize = sysBackupSize;
    e.sysBackupSch = sysBackupSch;
    e.sysGmail = sysGmail;
    e.sysDBId = sysDBId;
    e.sysCreated = sysCreated;
    e.sysModified = sysModified;

    final x = await DataBaseMain.insertSetting(e);
    if (x > 0) {
      setting.add(e);
      notifyListeners();
      // if (e.notifikasi == 1) {
      //   createReminder(e);
      // }
      r = Response(
          identifier: "success", message: "Setting berhasil ditambahkan");
    } else {
      r = Response(identifier: "error", message: "Terjadi kesalahan");
    }
    return r;
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

    await driveApi.files.delete(setting.first.sysDBId);
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

    final result = await driveApi.files.create(driveFile,
        uploadMedia: drive.Media(localFile.openRead(), localFile.lengthSync()));
    updateSetting(
        localFile.lengthSync().toString(),
        account.email,
        result.id,
        DateTime.now(),
        // DateFormat("dd-MM-yyyy HH:mm:ss").format(DateTime.now()).toString(),
        result.modifiedTime);

    initData();
    if (localFile.lengthSync() > int.parse(setting.first.sysBackupSize)) {
      await driveApi.files.delete(setting.first.sysDBId);
    }
    notifBackup();
  }

  Future<void> uploadtoGdriveSch() async {
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

    final result = await driveApi.files.create(driveFile,
        uploadMedia: drive.Media(localFile.openRead(), localFile.lengthSync()));
    updateSettingSch(
        localFile.lengthSync().toString(),
        DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 1,
            setting.first.sysBackupSch.hour,
            setting.first.sysBackupSch.minute),
        account.email,
        result.id,
        DateTime.now(),
        // DateFormat("dd-MM-yyyy HH:mm:ss").format(DateTime.now()).toString(),
        result.modifiedTime);

    initData();
    if (localFile.lengthSync() > int.parse(setting.first.sysBackupSize)) {
      await driveApi.files.delete(setting.first.sysDBId);
    }
    notifBackup();
  }

  Future<Response> updateSetting(
      String sysBackupSize,
      //  DateTime sysBackupSch,
      String sysGmail,
      String sysDBId,
      DateTime sysCreated,
      DateTime sysModified) async {
    Response r = Response();

    await DataBaseMain.db.updateSettingcol("sysBackupSize", sysBackupSize);
    await DataBaseMain.db.updateSettingcol("sysGmail", sysGmail);
    await DataBaseMain.db.updateSettingcol("sysDBId", sysDBId);
    await DataBaseMain.db
        .updateSettingcol("sysCreated", TimeValidator.getDatenTime(sysCreated));
    await DataBaseMain.db.updateSettingcol(
        "sysModified", TimeValidator.getDatenTime(sysModified));

    notifyListeners();
    return r;
  }

  Future<Response> updateSettingSch(
      String sysBackupSize,
      DateTime sysBackupSch,
      String sysGmail,
      String sysDBId,
      DateTime sysCreated,
      DateTime sysModified) async {
    Response r = Response();

    await DataBaseMain.db.updateSettingcol("sysBackupSize", sysBackupSize);
    await DataBaseMain.db.updateSettingcol("sysGmail", sysGmail);
    await DataBaseMain.db.updateSettingcol("sysDBId", sysDBId);
    await DataBaseMain.db
        .updateSettingcol("sysCreated", TimeValidator.getDatenTime(sysCreated));
    await DataBaseMain.db.updateSettingcol(
        "sysModified", TimeValidator.getDatenTime(sysModified));
    await DataBaseMain.db.updateSettingcol(
        "sysBackupSch", TimeValidator.getDatenTime(sysBackupSch));

    notifyListeners();
    return r;
  }

  Future<Response> updateScheduler(
    DateTime sysBackupSch,
  ) async {
    Response r = Response();

    await DataBaseMain.db.updateSettingcol(
        "sysBackupSch", TimeValidator.getDatenTime(sysBackupSch));

    notifyListeners();

    return r;
  }

  // Future<Response> deleteSetting(Setting _setting) async {
  //   Response r = Response();
  //   final list = await DataBaseMain.db
  //       .getSettingesBySettingID(_setting.settingId);
  //   if (list.isNotEmpty) {
  //     r = Response(
  //         identifier: "error", message: "Setting ini sedang digunakan");
  //   } else {
  //     final x = await DataBaseMain.deleteSetting(_setting);
  //     if (x > 0) {
  //       setting.removeWhere(
  //           (element) => element.settingId == _setting.settingId);
  //       notifyListeners();
  //       r = Response(
  //           identifier: "success", message: "Setting berhasil dihapus");
  //     } else {
  //       r = Response(identifier: "error", message: "Sucedio un error");
  //     }
  //   }
  //   return r;
  // }

  notifBackup() async {
    notificationManager.showNotification(
        999, "TechSupport", "Backup ke google");
  }
}
