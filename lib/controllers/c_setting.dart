import 'package:flutter/widgets.dart';
import 'package:googleapis/cloudresourcemanager/v2.dart';
import 'package:techsupport/api.dart';
import 'package:techsupport/utils.dart';
import 'package:techsupport/models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'dart:io' as io;
import 'package:ext_storage/ext_storage.dart';
import 'package:techsupport/utils/u_filesize.dart';
import 'dart:async';

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
  List<Images> images = [];
  List<ItemSetting> itemSetting = [];
  String languageCode;

  int selectedIndex = 0;
  TimeOfDay timeSelected = TimeOfDay.now();

//  SharedPreferences sharedPreferences;
  void getListSettings() async {
    _initData();
    notifyListeners();
  }

  _initData() async {
    setting.clear();
    final x = await DataBaseMain.getListSettings();
    setting = x;
    images.clear();
    images = await DataBaseMain.getListImagesbySync(1);
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

  void logoutFromGoogle() async {
    final googleSignIn =
        signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    final signIn.GoogleSignInAccount account = await googleSignIn.signOut();
    print("User account $account");
  }

  Future<void> downloadGdrive() async {
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
    var dir = await ExtStorage.getExternalStorageDirectory();
    var pathDB = "$dir/techsupport";
    var pathImage = "$pathDB/images";

    if (!io.Directory(pathDB).existsSync()) {
      io.Directory(pathDB).createSync(recursive: true);
    }
    if (!io.File("$pathDB/techsupport.db").existsSync()) {
      final saveFile = io.File("$pathDB/" + list.files[0].name);
      List<int> dataStore = [];
      file.stream.listen((data) {
        print("DataReceived: ${data.length}");
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
    if (!io.Directory(pathImage).existsSync()) {
      io.Directory(pathImage).createSync(recursive: true);
    }
    if (img.files.length > 0) {
      for (int i = 0; i < img.files.length; i++) {
        if (!io.File("$pathImage/" + img.files[i].name).existsSync()) {
          final saveFileImg = io.File("$pathImage/" + img.files[i].name);
          List<int> dataImage = [];
          file.stream.listen((dataImg) {
            print("DataReceived: ${dataImg.length}");
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

    // final directory = await getExternalStorageDirectory();
  }

  Future<void> uploadtoGdrive() async {
    final googleSignIn =
        signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    final signIn.GoogleSignInAccount account = await googleSignIn.signIn();
    //print("User account $account");

    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    // final test = await driveApi.files.list(q: "name = 'techsupport.db'");
    //print(test.toJson().toString());
    final getList = await driveApi.files
        .list(q: "mimeType = 'application/vnd.google-apps.folder'");
    // print(getList.toJson().toString());
    String folderId;
    if (getList.files.toList().where((e) => e.name == "techsupport").isEmpty) {
      final folder = await driveApi.files.create(
        drive.File()
          ..name = 'techsupport'
          ..mimeType =
              'application/vnd.google-apps.folder', // this defines its folder
      );

      // print(folder.toJson().toString());
      folderId = folder.id;
    } else {
      folderId = setting.first.sysDBId.split("|")[0];
    }
    var dir = await ExtStorage.getExternalStorageDirectory();
    final filename = "techsupport.db";
    var driveFile = new drive.File();
    driveFile.parents = [folderId];
    driveFile.name = filename;

    final localFile = io.File("$dir/techsupport/techsupport.db");

    try {
      if (setting.first.sysDBId.split("|").length == 2)
        await driveApi.files.delete(setting.first.sysDBId.split("|")[1]);
    } on Exception catch (e) {
      print(e.toString());
    }
    final result = await driveApi.files.create(driveFile,
        uploadMedia: drive.Media(localFile.openRead(), localFile.lengthSync()));
    updateSetting(
      localFile.lengthSync().toString(),
      account.email,
      folderId + "|" + result.id,
      DateTime.now(),
    );
    if (images.length > 0) {
      for (int i = 0; 0 < images.length; i++) {
        var driveImg = new drive.File();
        driveImg.parents = [folderId];
        driveImg.name = io.File(images[i].imgImage).path.split('/').last;
        try {
          await driveApi.files.delete(images[i].imgStr);
        } on Exception catch (e) {
          print(e.toString());
        }
        var img = await driveApi.files.create(driveImg,
            uploadMedia: drive.Media(io.File(images[i].imgImage).openRead(),
                io.File(images[i].imgImage).lengthSync()));
        await DataBaseMain.db
            .updateImagescol("imgStr", img.id, images[i].imgId);
        await DataBaseMain.db.updateImagescol("isSync", "2", images[i].imgId);
      }
    }
    notifBackup();

    _initData();
    // downloadfromGdrive();
    notifyListeners();
  }

  Future<void> uploadtoGdriveSch() async {
    _initData();
    // deletefromGdrive();
    final googleSignIn =
        signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    final signIn.GoogleSignInAccount account = await googleSignIn.signIn();
    //print("User account $account");

    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    final test = await driveApi.files.list(q: "name = 'techsupport.db'");
    //print(test.toJson().toString());
    final getList = await driveApi.files
        .list(q: "mimeType = 'application/vnd.google-apps.folder'");
    // print(getList.toJson().toString());
    String folderId;
    if (getList.files.toList().where((e) => e.name == "techsupport").isEmpty) {
      final folder = await driveApi.files.create(
        drive.File()
          ..name = 'techsupport'
          ..mimeType =
              'application/vnd.google-apps.folder', // this defines its folder
      );

      print(folder.toJson().toString());
      folderId = folder.id;
    } else {
      folderId = setting.first.sysDBId.split("|")[0];
    }
    var dir = await ExtStorage.getExternalStorageDirectory();
    final filename = "techsupport.db";
    var driveFile = new drive.File();
    driveFile.parents = [folderId];
    driveFile.name = filename;

    final localFile = io.File("$dir/techsupport/techsupport.db");

    try {
      if (setting.first.sysDBId.split("|").length == 2)
        await driveApi.files.delete(setting.first.sysDBId.split("|")[1]);
    } on Exception catch (e) {
      print(e.toString());
    }
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
      folderId + "|" + result.id,
      DateTime.now(),
    );

    if (images.length > 0) {
      for (int i = 0; 0 < images.length; i++) {
        var driveImg = new drive.File();
        driveImg.parents = [folderId];
        driveImg.name = io.File(images[i].imgImage).path.split('/').last;
        try {
          await driveApi.files.delete(images[i].imgStr);
        } on Exception catch (e) {
          print(e.toString());
        }
        var img = await driveApi.files.create(driveImg,
            uploadMedia: drive.Media(io.File(images[i].imgImage).openRead(),
                io.File(images[i].imgImage).lengthSync()));
        await DataBaseMain.db
            .updateImagescol("imgStr", img.id, images[i].imgId);
        await DataBaseMain.db.updateImagescol("isSync", "2", images[i].imgId);
      }
    }
    notifBackup();

    _initData();
    notifyListeners();
  }

  Future<Response> updateSetting(
      String sysBackupSize,
      //  DateTime sysBackupSch,
      String sysGmail,
      String sysDBId,
      DateTime sysCreated) async {
    Response r = Response();

    await DataBaseMain.db.updateSettingcol("sysBackupSize", sysBackupSize);
    await DataBaseMain.db.updateSettingcol("sysGmail", sysGmail);
    await DataBaseMain.db.updateSettingcol("sysDBId", sysDBId);
    await DataBaseMain.db
        .updateSettingcol("sysCreated", TimeValidator.getDatenTime(sysCreated));

    notifyListeners();
    return r;
  }

  Future<Response> updateSettingSch(String sysBackupSize, DateTime sysBackupSch,
      String sysGmail, String sysDBId, DateTime sysCreated) async {
    Response r = Response();

    await DataBaseMain.db.updateSettingcol("sysBackupSize", sysBackupSize);
    await DataBaseMain.db.updateSettingcol("sysGmail", sysGmail);
    await DataBaseMain.db.updateSettingcol("sysDBId", sysDBId);
    await DataBaseMain.db
        .updateSettingcol("sysCreated", TimeValidator.getDatenTime(sysCreated));

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

class ListDrive {
  String fileId;
  String fileName;

  ListDrive();
}
