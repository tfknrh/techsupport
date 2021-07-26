import 'package:flutter/material.dart';
import 'package:techsupport/utils/u_time.dart';

import 'package:techsupport/utils/u_colorHex.dart';

class Aktivitas with ChangeNotifier {
  int aktivitasId;
  String aktivitasName;
  String description;
  TimeOfDay timeStart;
  TimeOfDay timeFinish;
  DateTime dateTime;
  int notifikasi;
  int aktivitasType;
  int isAlarm;
  int categoryId;
  int customerId;
  String categoryName;
  String customerName;
  Color color;
  int isStatus;

  Aktivitas();

  factory Aktivitas.fromBD(Map json) {
    Aktivitas aktivitas = Aktivitas();
    aktivitas.aktivitasId = json['aktivitasId'];
    aktivitas.aktivitasName = json['aktivitasName'];
    aktivitas.description = json['description'];
    aktivitas.timeStart = TimeValidator.stringToTimeOfDay(json['timeStart']);
    aktivitas.timeFinish = TimeValidator.stringToTimeOfDay(json['timeEnd']);
    aktivitas.dateTime = TimeValidator.stringtoDate(json['dateTime']);
    aktivitas.notifikasi = json['notifikasi'];
    aktivitas.isAlarm = json['isAlarm'];
    aktivitas.aktivitasType = json['type'];
    aktivitas.categoryId = json['categoryId'];
    aktivitas.customerId = json['customerId'];
    // aktivitas.categoryName = json['categoryName'];

    // aktivitas.color = HexColor(json['color']);
    // aktivitas.customerName = json['customerName'];
    aktivitas.isStatus = json['isStatus'];
    return aktivitas;
  }

  Map<String, dynamic> toBD() {
    var map = <String, dynamic>{
      'aktivitasId': this.aktivitasId,
      'aktivitasName': this.aktivitasName,
      'description': this.description,
      'timeStart': TimeValidator.getHora(this.timeStart),
      'timeEnd': TimeValidator.getHora(this.timeFinish),
      'dateTime': TimeValidator.getDateTime(this.dateTime),
      'notifikasi': this.notifikasi,
      'isAlarm': this.isAlarm,
      'type': this.aktivitasType,
      'categoryId': this.categoryId,
      'customerId': this.customerId,
      'isStatus': this.isStatus
    };
    return map;
  }

  update(Aktivitas aktivitas) {
    this.timeStart = aktivitas.timeStart;
    this.timeFinish = aktivitas.timeFinish;
    this.dateTime = aktivitas.dateTime;
  }

  factory Aktivitas.clone(Aktivitas a) {
    Aktivitas aktivitas = Aktivitas();
    aktivitas.aktivitasId = a.aktivitasId;
    aktivitas.aktivitasName = a.aktivitasName;
    aktivitas.description = a.description;
    aktivitas.timeStart = a.timeStart;
    aktivitas.timeFinish = a.timeFinish;
    aktivitas.dateTime = a.dateTime;
    aktivitas.notifikasi = a.notifikasi;
    aktivitas.isAlarm = a.isAlarm;
    aktivitas.aktivitasType = a.aktivitasType;
    aktivitas.categoryId = a.categoryId;
    aktivitas.customerId = a.customerId;
    aktivitas.isStatus = a.isStatus;
    aktivitas.color = a.color;
    aktivitas.categoryName = a.categoryName;
    aktivitas.customerName = a.customerName;
    return aktivitas;
  }
}