import 'package:flutter/widgets.dart';
import 'package:techsupport/api/a_db.dart';
import 'package:techsupport/api/a_response.dart';
import 'package:techsupport/models/m_category.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> category = [];

  void obtenerCategorys() async {
    final x = await DataBaseMain.obtenerCategorys();
    category = x;
    notifyListeners();
  }

  void update() {
    notifyListeners();
  }

  List<String> get getCategory {
    List<String> names = [];
    category.map((value) {
      names.add(value.categoryName);
    }).toList(); // Added here
    return names;
  }

  Future<Response> addCategory(String categoryName, Color color) async {
    Response r = Response();
    Category e = Category();
    e.categoryName = categoryName;
    e.color = color;
    final x = await DataBaseMain.insertCategory(e);
    if (x > 0) {
      e.categoryId = x;
      category.add(e);
      notifyListeners();
      r = Response(
          identifier: "success", message: "Kategori berhasil ditambahkan");
    } else {
      r = Response(identifier: "error", message: "Terjadi kesalahan");
    }
    return r;
  }

  Future<Response> updateCategory(
      int id, String categoryName, Color color) async {
    Response r = Response();
    Category e = Category();
    e.categoryName = categoryName;
    e.color = color;
    e.categoryId = id;
    final x = await DataBaseMain.updateCategory(e);
    if (x > 0) {
      //e.id = x;
      category.singleWhere((es) => es.categoryId == e.categoryId).categoryName =
          categoryName;
      category.singleWhere((es) => es.categoryId == e.categoryId).color = color;
      notifyListeners();
      r = Response(
          identifier: "success", message: "Kategori berhasil diperbarui");
    } else {
      r = Response(identifier: "error", message: "Terjadi kesalahan");
    }
    return r;
  }

  Future<Response> deleteCategory(Category etiqueta) async {
    Response r = Response();
    final list =
        await DataBaseMain.db.getAktivitasesByCategoryID(etiqueta.categoryId);
    if (list.isNotEmpty) {
      r = Response(
          identifier: "error", message: "Kategori ini sedang digunakan");
    } else {
      final x = await DataBaseMain.deleteCategory(etiqueta);
      if (x > 0) {
        category.removeWhere(
            (element) => element.categoryId == etiqueta.categoryId);
        notifyListeners();
        r = Response(
            identifier: "success", message: "Kategori berhasil dihapus");
      } else {
        r = Response(identifier: "error", message: "Sucedio un error");
      }
    }
    return r;
  }
}
