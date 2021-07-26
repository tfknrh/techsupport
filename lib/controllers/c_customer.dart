import 'package:flutter/widgets.dart';
import 'package:techsupport/api/a_db.dart';
import 'package:techsupport/api/a_response.dart';
import 'package:techsupport/models/m_customer.dart';

class CustomerProvider with ChangeNotifier {
  List<Customer> customer = [];

  void getListCustomers() async {
    final x = await DataBaseMain.getListCustomers();
    customer = x;
    notifyListeners();
  }

  void update() {
    notifyListeners();
  }

  List<String> get getCustomer {
    List<String> names = [];
    customer.map((value) {
      names.add(value.customerName);
    }).toList(); // Added here
    return names;
  }

  Future<Response> addCustomer(
      String customerName,
      String customerDesc,
      String customerLocation,
      String customerGps,
      String customerPic,
      String customerAkses) async {
    Response r = Response();
    Customer e = Customer();
    e.customerName = customerName;
    e.customerDesc = customerDesc;
    e.customerLocation = customerLocation;
    e.customerGps = customerGps;
    e.customerPic = customerPic;
    e.customerAkses = customerAkses;

    final x = await DataBaseMain.insertCustomer(e);
    if (x > 0) {
      e.customerId = x;
      customer.add(e);
      notifyListeners();
      r = Response(
          identifier: "success", message: "Customer berhasil ditambahkan");
    } else {
      r = Response(identifier: "error", message: "Terjadi kesalahan");
    }
    return r;
  }

  Future<Response> updateCustomer(
      int customerId,
      String customerName,
      String customerDesc,
      String customerLocation,
      String customerGps,
      String customerPic,
      String customerAkses) async {
    Response r = Response();
    Customer e = Customer();
    e.customerId = customerId;
    e.customerName = customerName;
    e.customerDesc = customerDesc;
    e.customerLocation = customerLocation;
    e.customerGps = customerGps;
    e.customerPic = customerPic;
    e.customerAkses = customerAkses;

    final x = await DataBaseMain.updateCustomer(e);
    if (x > 0) {
      //e.id = x;
      customer.singleWhere((es) => es.customerId == e.customerId).customerName =
          customerName;

      notifyListeners();
      r = Response(
          identifier: "success", message: "Kategori berhasil diperbarui");
    } else {
      r = Response(identifier: "error", message: "Terjadi kesalahan");
    }
    return r;
  }

  Future<Response> deleteCustomer(Customer _customer) async {
    Response r = Response();
    final list =
        await DataBaseMain.db.getAktivitasesByCustomerID(_customer.customerId);
    if (list.isNotEmpty) {
      r = Response(
          identifier: "error", message: "Customer ini sedang digunakan");
    } else {
      final x = await DataBaseMain.deleteCustomer(_customer);
      if (x > 0) {
        customer.removeWhere(
            (element) => element.customerId == _customer.customerId);
        notifyListeners();
        r = Response(
            identifier: "success", message: "Customer berhasil dihapus");
      } else {
        r = Response(identifier: "error", message: "Sucedio un error");
      }
    }
    return r;
  }
}
