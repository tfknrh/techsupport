import 'package:flutter/material.dart';
import 'package:techsupport/utils/u_colorHex.dart';

class Formulir {
  int formId;
  int formType;
  String formName;
  String formValue;
  int categoryId;

  Formulir();

  factory Formulir.fromBD(Map<String, dynamic> json) {
    Formulir e = new Formulir();
    e.formId = json["formId"];
    e.formType = json["formType"];
    e.formName = json["formName"];
    e.formValue = json["formValue"];
    e.categoryId = json["categoryId"];
    return e;
  }

  Map<String, dynamic> toBD() {
    var map = <String, dynamic>{
      'formId': this.formId,
      'formType': this.formType,
      'formName': this.formName,
      'formValue': this.formValue,
      'categoryId': this.categoryId,
    };
    return map;
  }
}
