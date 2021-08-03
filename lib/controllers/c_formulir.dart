import 'package:flutter/widgets.dart';
import 'package:techsupport/api.dart';
import 'package:techsupport/models.dart';

class FormulirProvider with ChangeNotifier {
  List<Formulir> formulir = [];
//List<Formulir> textFieldList = [];
  List<TextEditingController> controllers = [];

  void getListFormulirs() async {
    final x = await DataBaseMain.getListFormulirs();
    formulir = x;
    notifyListeners();
  }

  void update() {
    notifyListeners();
  }

  //list of controllers

  void addTextField() {
    formulir.add(Formulir());
    notifyListeners();
  }

  List<String> get getFormulir {
    List<String> names = [];
    formulir.map((value) {
      names.add(value.formName);
    }).toList(); // Added here
    return names;
  }

  Future<Response> addFormulir(
      int formType, String formName, String formValue, int categoryId) async {
    Response r = Response();
    Formulir e = Formulir();
    e.formName = formName;
    e.formType = formType;
    e.formValue = formValue;
    e.categoryId = categoryId;
    final x = await DataBaseMain.insertFormulir(e);
    if (x > 0) {
      e.formId = x;
      formulir.add(e);
      notifyListeners();
      r = Response(
          identifier: "success", message: "Kategori berhasil ditambahkan");
    } else {
      r = Response(identifier: "error", message: "Terjadi kesalahan");
    }
    return r;
  }

  Future<Response> updateFormulir(
      int formType, String formName, String formValue, int categoryId) async {
    Response r = Response();
    Formulir e = Formulir();
    e.formName = formName;
    e.formType = formType;
    e.formValue = formValue;
    e.categoryId = categoryId;
    final x = await DataBaseMain.updateFormulir(e);
    if (x > 0) {
      //e.id = x;
      formulir.singleWhere((es) => es.formId == e.formId).formName = formName;
      formulir.singleWhere((es) => es.formId == e.formId).formType = formType;
      formulir.singleWhere((es) => es.formId == e.formId).formValue = formValue;
      formulir.singleWhere((es) => es.formId == e.formId).categoryId =
          categoryId;

      notifyListeners();
      r = Response(
          identifier: "success", message: "Kategori berhasil diperbarui");
    } else {
      r = Response(identifier: "error", message: "Terjadi kesalahan");
    }
    return r;
  }

  Future<Response> deleteFormulir(Formulir form) async {
    Response r = Response();
    final list = await DataBaseMain.db.getAktivitasesByCategoryID(form.formId);
    if (list.isNotEmpty) {
      r = Response(
          identifier: "error", message: "Kategori ini sedang digunakan");
    } else {
      final x = await DataBaseMain.deleteFormulir(form);
      if (x > 0) {
        formulir.removeWhere((element) => element.formId == form.formId);
        notifyListeners();
        r = Response(
            identifier: "success", message: "Kategori berhasil dihapus");
      } else {
        r = Response(identifier: "error", message: "Terjadi Kesalahan");
      }
    }
    return r;
  }
}
