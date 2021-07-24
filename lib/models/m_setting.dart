import 'package:flutter/material.dart';
import 'package:techsupport/utils/u_colorHex.dart';

class Setting {
  int sysCountAkt;
  int sysCountCust;
  int sysCountImg;
  String sysBackupSize;
  String sysBackupSch;
  String sysGmail;
  String sysDBId;
  String sysCreated;
  String sysModified;

  Setting();

  factory Setting.fromJson(Map<String, dynamic> json) {
    Setting e = new Setting();
    e.sysCountAkt = json["sysCountAkt"];
    e.sysCountCust = json["sysCountCust"];
    e.sysCountImg = json["sysCountImg"];
    e.sysBackupSize = json["sysBackupSize"];
    e.sysBackupSch = json["sysBackupSch"];
    e.sysGmail = json["sysGmail"];
    e.sysDBId = json["sysDBId"];
    e.sysCreated = json["sysCreated"];
    e.sysModified = json["sysModified"];
    return e;
  }

  Map<String, dynamic> toBD() {
    var map = <String, dynamic>{
      "sysCountAkt": sysCountAkt,
      "sysCountCust": sysCountCust,
      "sysCountImg": sysCountImg,
      "sysBackupSize": sysBackupSize,
      "sysBackupSch": sysBackupSch,
      "sysGmail": sysGmail,
      "sysDBId": sysDBId,
      "sysCreated": sysCreated,
      "sysModified": sysModified
    };
    return map;
  }
}
