import 'package:flutter/widgets.dart';
import 'package:techsupport/api.dart';
import 'package:techsupport/models.dart';

class ImagesProvider with ChangeNotifier {
  List<Images> images = [];

  void getListImagess() async {
    final x = await DataBaseMain.getListImages();
    images = x;
    notifyListeners();
  }

  void update() {
    notifyListeners();
  }

  List<String> get getImages {
    List<String> names = [];
    images.map((value) {
      names.add(value.imgName);
    }).toList(); // Added here
    return names;
  }

  Future<Response> addImages(String imgImage, String imgName, String imgStr,
      int isSync, int aktivitasId) async {
    Response r = Response();
    Images e = Images();
    e.imgName = imgName;
    e.imgImage = imgImage;
    e.imgStr = imgStr;
    e.isSync = isSync;
    e.aktivitasId = aktivitasId;
    final x = await DataBaseMain.insertImages(e);
    if (x > 0) {
      e.imgId = x;
      images.add(e);
      notifyListeners();
      r = Response(
          identifier: "success", message: "Images berhasil ditambahkan");
    } else {
      r = Response(identifier: "error", message: "Terjadi kesalahan");
    }
    return r;
  }

  Future<Response> updateImages(String imgImage, String imgName, String imgStr,
      int isSync, int aktivitasId) async {
    Response r = Response();
    Images e = Images();
    e.imgName = imgName;
    e.imgImage = imgImage;
    e.imgStr = imgStr;
    e.isSync = isSync;
    e.aktivitasId = aktivitasId;
    final x = await DataBaseMain.updateImages(e);
    if (x > 0) {
      //e.id = x;
      images.singleWhere((es) => es.imgId == e.imgId).imgName = imgName;
      images.singleWhere((es) => es.imgId == e.imgId).imgImage = imgImage;

      images.singleWhere((es) => es.imgId == e.imgId).imgStr = imgStr;
      images.singleWhere((es) => es.imgId == e.imgId).isSync = isSync;
      images.singleWhere((es) => es.imgId == e.imgId).aktivitasId = aktivitasId;
      notifyListeners();
      r = Response(
          identifier: "success", message: "Images berhasil diperbarui");
    } else {
      r = Response(identifier: "error", message: "Terjadi kesalahan");
    }
    return r;
  }

  Future<Response> deleteImages(Images img) async {
    Response r = Response();
    final list =
        await DataBaseMain.db.getAktivitasesByAktivitasID(img.aktivitasId);
    if (list.isNotEmpty) {
      r = Response(identifier: "error", message: "Images ini sedang digunakan");
    } else {
      final x = await DataBaseMain.deleteImages(img);
      if (x > 0) {
        images.removeWhere((element) => img.imgId == img.imgId);
        notifyListeners();
        r = Response(identifier: "success", message: "Images berhasil dihapus");
      } else {
        r = Response(identifier: "error", message: "Terjadi kesalahan");
      }
    }
    return r;
  }
}
