import 'package:techsupport/utils.dart';

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
    return e;
  }

  Map<String, dynamic> toBD() {
    var map = <String, dynamic>{
      "sysCountAkt": sysCountAkt,
      "sysCountCust": sysCountCust,
      "sysCountImg": sysCountImg,
      "sysBackupSize": sysBackupSize,
      "sysBackupSch": TimeValidator.getDatenTime(sysBackupSch),
      "sysGmail": sysGmail,
      "sysDBId": sysDBId,
      "sysCreated": TimeValidator.getDatenTime(sysCreated),
      "sysModified": TimeValidator.getDatenTime(sysModified),
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
