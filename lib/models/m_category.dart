import 'package:flutter/material.dart';
import 'package:techsupport/utils/u_colorHex.dart';

class Category {
  int categoryId;
  String categoryName;
  Color color;
  int canDelete;

  Category();

  factory Category.fromJson(Map<String, dynamic> json) {
    Category e = new Category();
    e.categoryId = json["categoryId"];
    e.categoryName = json["categoryName"];
    e.color = HexColor(json["color"]);
    e.canDelete = json["candelete"];
    return e;
  }

  Map<String, dynamic> toBD() {
    var map = <String, dynamic>{
      'categoryId': this.categoryId,
      'color': HexColorMaterial.colorToHext(this.color),
      'categoryName': this.categoryName,
      'candelete': 1,
    };
    return map;
  }
}
