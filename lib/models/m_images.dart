class ImagesAttrb {
  final Map<String, dynamic> _data;

  ImagesAttrb(this._data);

  dynamic get imgId => _data["imgId"];
  String get imgImage => _data["imgImage"];
  String get imgName => _data["imgName"];
  dynamic get aktivitasId => _data["aktivitasId"];

  Map<String, dynamic> toMap() {
    return {
      "imgImage": imgImage,
      "imgName": imgName,
      "aktivitasId": aktivitasId
    };
  }

  String toString() {
    return toMap().toString();
  }
}
