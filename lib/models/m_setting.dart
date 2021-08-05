import 'package:techsupport/utils.dart';
import 'package:flutter/material.dart';

class Setting {
  int sysCountAkt;
  int sysCountCust;
  int sysCountImg;
  String sysBackupSize;
  DateTime sysBackupSch;
  String sysGmail;
  String sysDBId;
  DateTime sysCreated;
  DateTime sysModified;
  String sysTheme;
  Color sysColor;

  Setting();

  factory Setting.fromJson(Map<String, dynamic> json) {
    Setting e = new Setting();
    e.sysCountAkt = json["sysCountAkt"];
    e.sysCountCust = json["sysCountCust"];
    e.sysCountImg = json["sysCountImg"];
    e.sysBackupSize = json["sysBackupSize"];
    e.sysBackupSch = TimeValidator.stringtoDateTime(json["sysBackupSch"]);
    e.sysGmail = json["sysGmail"];
    e.sysDBId = json["sysDBId"];
    e.sysCreated = TimeValidator.stringtoDateTime(json["sysCreated"]);
    e.sysModified = TimeValidator.stringtoDateTime(json["sysModified"]);
    e.sysTheme = json["sysTheme"];
    e.sysColor = HexColor(json["sysColor"]);
    return e;
  }

  Map<String, dynamic> toBD() {
    var map = <String, dynamic>{
      "sysCountAkt": this.sysCountAkt,
      "sysCountCust": this.sysCountCust,
      "sysCountImg": this.sysCountImg,
      "sysBackupSize": this.sysBackupSize,
      "sysBackupSch": TimeValidator.getDatenTime(this.sysBackupSch),
      "sysGmail": this.sysGmail,
      "sysDBId": this.sysDBId,
      "sysCreated": TimeValidator.getDatenTime(this.sysCreated),
      "sysModified": TimeValidator.getDatenTime(this.sysModified),
      "sysTheme": this.sysTheme,
      "sysColor": HexColorMaterial.colorToHext(this.sysColor),
    };
    return map;
  }
}

class ItemSetting {
  //final Widget leading;
  // final Widget trailing;
  final int tipe;
  final String title;
  final String subtitle;
  final String group;
  ItemSetting({this.title, this.subtitle, this.group, this.tipe});
}
