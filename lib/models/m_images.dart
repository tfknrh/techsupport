import 'package:flutter/material.dart';
import 'package:techsupport/utils/u_colorHex.dart';

class Images {
  int imgId;
  String imgName;
  String imgImage;
  int aktivitasId;
  String imgStr;
  int isSync;
  //String aktivitasName;

  Images();

  factory Images.fromJson(Map<String, dynamic> json) {
    Images e = new Images();
    e.imgId = json["imgId"];
    e.imgName = json["imgName"];
    e.imgImage = json["imgImage"];
    e.aktivitasId = json["aktivitasId"];
    e.imgStr = json["imgStr"];
    e.isSync = json["isSync"];
    return e;
  }

  Map<String, dynamic> toBD() {
    var map = <String, dynamic>{
      'imgId': this.imgId,
      'imgName': this.imgName,
      'imgImage': this.imgImage,
      'aktivitasId': this.aktivitasId,
      'imgStr': this.imgStr,
      'isSync': this.isSync,
    };
    return map;
  }
}
