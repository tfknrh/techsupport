import 'package:flutter/widgets.dart';
import 'package:techsupport/api.dart';
import 'package:techsupport/utils.dart';
import 'package:techsupport/models.dart';
import 'package:flutter/material.dart';

//import 'package:shared_preferences/shared_preferences.dart';

class AktivitasProvider with ChangeNotifier {
  NotificationManager notificationManager = NotificationManager();
  List<Aktivitas> aktivitas = [];
  List<Customer> customer = [];

  int selectedIndex = 0;
  DateTime daySelected = DateTime.now();

//  SharedPreferences sharedPreferences;
  void getListAktivitass() async {
    final x = await DataBaseMain.getListAktivitass();
    aktivitas = x;
    notifyListeners();
  }

  void getListCustomers() async {
    final x = await DataBaseMain.getListCustomers();
    customer = x;
    notifyListeners();
  }

  Future<void> initData() async {
    aktivitas.clear();
    aktivitas = await DataBaseMain.db.getAktivitas();
    //  await DataBaseMain.db
    //     .getAktivitasesByWeekDay(DateFormat("yyyy-MM-dd").format(daySelected));
    //aktivitas.sort((a, b) => longerTime(a.timeStart, b.timeStart));
    // listAktivitas = List.from(setVaciousTimes(listAktivitas));
    notifyListeners();
  }

  int longerTime(TimeOfDay t1, TimeOfDay t2) {
    DateTime h = DateTime.now();
    DateTime x1 = DateTime(h.year, h.month, h.day, t1.hour, t1.minute, 0);
    DateTime x2 = DateTime(h.year, h.month, h.day, t2.hour, t2.minute, 0);
    return x1.difference(x2).inSeconds;
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

  Future<Response> addAktivitas(
      //  int aktivitasId,
      String aktivitasName,
      String description,
      String timeStart,
      String timeFinish,
      String dateTime,
      int notifikasi,
      int aktivitasType,
      int isAlarm,
      int categoryId,
      int customerId,
      int isStatus,
      String formValue) async {
    Response r = Response();
    Aktivitas e = Aktivitas();
    // e.aktivitasId = aktivitasId;
    e.aktivitasName = aktivitasName;
    e.description = description;
    e.timeStart = TimeValidator.stringToTimeOfDay(timeStart);
    e.timeFinish = TimeValidator.stringToTimeOfDay(timeFinish);
    e.dateTime = TimeValidator.stringtoDate(dateTime);
    e.notifikasi = notifikasi;
    e.isAlarm = isAlarm;
    e.aktivitasType = aktivitasType;
    e.categoryId = categoryId;
    e.customerId = customerId;
    e.isStatus = isStatus;
    e.formValue = formValue;

    final x = await DataBaseMain.insertAktivitas(e);
    if (x > 0) {
      e.aktivitasId = x;
      aktivitas.add(e);
      notifyListeners();
      if (e.notifikasi == 1) {
        createReminder(e);
      }
      r = Response(
          identifier: "success", message: "Aktivitas berhasil ditambahkan");
    } else {
      r = Response(identifier: "error", message: "Terjadi kesalahan");
    }
    return r;
  }

  Future<Response> updateAktivitas(
      int aktivitasId,
      String aktivitasName,
      String description,
      String timeStart,
      String timeFinish,
      String dateTime,
      int notifikasi,
      int aktivitasType,
      int isAlarm,
      int categoryId,
      int customerId,
      int isStatus,
      String formValue) async {
    Response r = Response();
    Aktivitas e = Aktivitas();
    e.aktivitasId = aktivitasId;
    e.aktivitasName = aktivitasName;
    e.description = description;
    e.timeStart = TimeValidator.stringToTimeOfDay(timeStart);
    e.timeFinish = TimeValidator.stringToTimeOfDay(timeFinish);
    e.dateTime = TimeValidator.stringtoDate(dateTime);
    e.notifikasi = notifikasi;
    e.isAlarm = isAlarm;
    e.aktivitasType = aktivitasType;
    e.categoryId = categoryId;
    e.customerId = customerId;
    e.isStatus = isStatus;
    e.formValue = formValue;

    final x = await DataBaseMain.updateAktivitas(e);

    if (x > 0) {
      //e.id = x;
      // aktivitas
      //     .singleWhere((es) => es.aktivitasId == e.aktivitasId)
      //     .customerId = customerId;

      notifyListeners();
      notificationManager.removeReminder(e.aktivitasId);

      if (e.notifikasi == 1) {
        createReminder(e);
      }
      r = Response(
          identifier: "success", message: "Aktivitas berhasil diperbarui");
    } else {
      r = Response(identifier: "error", message: "Terjadi kesalahan");
    }
    return r;
  }

  // Future<Response> deleteAktivitas(Aktivitas _aktivitas) async {
  //   Response r = Response();
  //   final list = await DataBaseMain.db
  //       .getAktivitasesByAktivitasID(_aktivitas.aktivitasId);
  //   if (list.isNotEmpty) {
  //     r = Response(
  //         identifier: "error", message: "Aktivitas ini sedang digunakan");
  //   } else {
  //     final x = await DataBaseMain.deleteAktivitas(_aktivitas);
  //     if (x > 0) {
  //       aktivitas.removeWhere(
  //           (element) => element.aktivitasId == _aktivitas.aktivitasId);
  //       notifyListeners();
  //       r = Response(
  //           identifier: "success", message: "Aktivitas berhasil dihapus");
  //     } else {
  //       r = Response(identifier: "error", message: "Sucedio un error");
  //     }
  //   }
  //   return r;
  // }
  Future<Response> deleteAktivitas(Aktivitas _aktivitas) async {
    Response serviceResponse = Response();
    _aktivitas.aktivitasType = 1;
    serviceResponse.identifier = 'success';
    serviceResponse.message = "Waktu valid";
    final re = await DataBaseMain.db.deleteAktivitas(_aktivitas);
    if (re > 0) {
      serviceResponse.identifier = 'success';
      serviceResponse.message = "Aktivitas berhasil ditambahkan";
      notificationManager.removeReminder(_aktivitas.aktivitasId);
    } else {
      serviceResponse.identifier = 'error';
      serviceResponse.message = "Data tidak dapat disimpan";
    }
    return serviceResponse;
  }

  createReminder(Aktivitas _aktivitas) async {
    final c = await DataBaseMain.getListCustomerbyID(_aktivitas.customerId);

    notificationManager.showNotificationSpecificTime(
        _aktivitas.aktivitasId,
        //  "Task Manager",

        "${c.customerName} - ${_aktivitas.aktivitasName}",
        _aktivitas.description,

        // actividad.weekDay + 1,
        DateTime(
            _aktivitas.dateTime.year,
            _aktivitas.dateTime.month,
            _aktivitas.dateTime.day,
            _aktivitas.timeStart.hour,
            _aktivitas.timeStart.minute,
            0),
        _aktivitas.aktivitasId.toString());
  }
}
