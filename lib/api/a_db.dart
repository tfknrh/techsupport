import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:techsupport/models/m_aktivitas.dart';
import 'package:techsupport/models/m_category.dart';
import 'package:techsupport/models/m_customer.dart';
import 'package:techsupport/models/m_setting.dart';

import 'package:techsupport/utils/u_time.dart';
import 'package:techsupport/SQL.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:ext_storage/ext_storage.dart';

class DataBaseMain {
  DataBaseMain._();

  static final DataBaseMain db = DataBaseMain._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDb();
    return _database;
  }

  initDb() async {
    // Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // String path = join(documentsDirectory.path, 'TaskManagerDB1.db');
    var dir = await ExtStorage.getExternalStorageDirectory();
    if (!Directory("$dir/techsupport").existsSync()) {
      Directory("$dir/techsupport").createSync(recursive: true);
    }
    //Directory documentsDirectory = await getExternalStorageDirectory();
    String path = join("$dir/techsupport", "techsupport.db");
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute("""CREATE TABLE Category (
          categoryId INTEGER PRIMARY KEY AUTOINCREMENT,
          categoryName TEXT ,
          color TEXT,
           candelete Integer)""");
    await db.execute("""CREATE TABLE Aktivitas (
          aktivitasId INTEGER PRIMARY KEY AUTOINCREMENT,
          aktivitasName TEXT,
          description TEXT,
            timeStart TEXT,
            timeEnd TEXT,
            dateTime TEXT,
             notifikasi INTEGER,
             isAlarm INTEGER,
              type INTEGER,
              categoryId Integer,
             customerId INTEGER,
             isStatus INTEGER)""");

    await db.execute("""CREATE TABLE Customer (
      customerId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      customerName TEXT NOT NULL,
      customerDesc TEXT NOT NULL,
      customerLocation TEXT,
       customerGps TEXT,
       customerPic TEXT,
      customerAkses TEXT)""");

    await db.execute(
        "INSERT INTO Category(categoryName,color,candelete) values('Installasi','ffDD3100',0)");
    await db.execute(
        "INSERT INTO Category(categoryName,color,candelete) values('Maintenance','ff913D00',0)");
    await db.execute(
        "INSERT INTO Category(categoryName,color,candelete) values('Meeting','ff5677FC',0)");
    await db.execute(
        "INSERT INTO Category(categoryName,color,candelete) values('Update','ff1A951E',0)");
    await db.execute(
        "INSERT INTO Category(categoryName,color,candelete) values('Re-Install','ff683BB7',0)");
    await db.execute(
        "INSERT INTO Category(categoryName,color,candelete) values('Pengecekan System','ff683BB7',0)");
    await db.execute(
        "INSERT INTO Category(categoryName,color,candelete) values('Training','ff683BB7',0)");
    await db.execute(
        "INSERT INTO Category(categoryName,color,candelete) values('Lain-lain','ff683BB7',0)");
  }

  static Future<List<Aktivitas>> onItemSearch(
      List<Aktivitas> list, String val) async {
    if (list.any((element) =>
        element.aktivitasName.toLowerCase().contains(val.toLowerCase()))) {
      /// return list which contains text matches
      return list
          .where((element) =>
              element.categoryName.toLowerCase().contains(val.toLowerCase()))
          .toList();
    }
    return [];
  }

  static Future<List<Aktivitas>> obtenerAktivitass() async {
    final db = await DataBaseMain.db.database;
    final res = await db.query('Aktivitas');
    List<Aktivitas> list =
        res.isNotEmpty ? res.map((c) => Aktivitas.fromBD(c)).toList() : [];
    for (var i = 0; i < list.length; i++) {
      final _category = await obtenerCategorybyID(list[i].categoryId);
      final _customer = await obtenerCustomerbyID(list[i].customerId);
      list[i].color = _category.color;
      list[i].categoryName = _category.categoryName;
      list[i].customerName = _customer.customerName;
    }
    return list;
  }

  static Future<Aktivitas> obtenerAktivitasbyID(int id) async {
    final db = await DataBaseMain.db.database;
    final res =
        await db.rawQuery(SQL.queryAktivitas + ' where aktivitasId = ?', [id]);
    List<Aktivitas> list =
        res.isNotEmpty ? res.map((c) => Aktivitas.fromBD(c)).toList() : [];
    for (var i = 0; i < list.length; i++) {
      final _category = await obtenerCategorybyID(list[i].categoryId);
      final _customer = await obtenerCustomerbyID(list[i].customerId);
      list[i].color = _category.color;
      list[i].categoryName = _category.categoryName;
      list[i].customerName = _customer.customerName;
    }
    return list.isEmpty ? null : list[0];
  }

  static Future<int> insertAktivitas(Aktivitas _aktivitas) async {
    final db = await DataBaseMain.db.database;
    var raw = await db.insert('Aktivitas', _aktivitas.toBD());
    return raw;
  }

  static Future<int> updateAktivitas(Aktivitas _aktivitas) async {
    final db = await DataBaseMain.db.database;
    var raw = await db.update('Aktivitas', _aktivitas.toBD(),
        where: "aktivitasId = ?", whereArgs: [_aktivitas.aktivitasId]);
    return raw;
  }

  Future<int> deleteAktivitas(Aktivitas _aktivitas) async {
    final db = await DataBaseMain.db.database;
    var raw = await db.delete('Aktivitas',
        where: 'aktivitasId = ${_aktivitas.aktivitasId}');
    return raw;
  }

  // #endregion
  // #region Categorys
  static Future<List<Category>> obtenerCategorys() async {
    final db = await DataBaseMain.db.database;
    final res = await db.query('Category');
    List<Category> list =
        res.isNotEmpty ? res.map((c) => Category.fromJson(c)).toList() : [];
    return list;
  }

  static Future<Category> obtenerCategorybyID(int id) async {
    final db = await DataBaseMain.db.database;
    final res =
        await db.rawQuery('select * from Category where categoryId = ?', [id]);
    List<Category> list =
        res.isNotEmpty ? res.map((c) => Category.fromJson(c)).toList() : [];
    return list.isEmpty ? null : list[0];
  }

  static Future<int> insertCategory(Category _category) async {
    final db = await DataBaseMain.db.database;
    var raw = await db.insert('Category', _category.toBD());
    return raw;
  }

  static Future<int> updateCategory(Category _category) async {
    final db = await DataBaseMain.db.database;
    var raw = await db.update('Category', _category.toBD(),
        where: "categoryId = ?", whereArgs: [_category.categoryId]);
    return raw;
  }

  static Future<int> deleteCategory(Category _category) async {
    final db = await DataBaseMain.db.database;
    var raw = await db.delete('Category',
        where: 'categoryId = ${_category.categoryId}');
    return raw;
  }

  // #endregion
// #region Customer
  static Future<List<Customer>> obtenerCustomers() async {
    final db = await DataBaseMain.db.database;
    final res = await db.query('Customer');
    List<Customer> list =
        res.isNotEmpty ? res.map((c) => Customer.fromJson(c)).toList() : [];
    return list;
  }

  static Future<Customer> obtenerCustomerbyID(int id) async {
    final db = await DataBaseMain.db.database;
    final res =
        await db.rawQuery('select * from Customer where customerId = ?', [id]);
    List<Customer> list =
        res.isNotEmpty ? res.map((c) => Customer.fromJson(c)).toList() : [];
    return list.isEmpty ? null : list[0];
  }

  static Future<int> insertCustomer(Customer _customer) async {
    final db = await DataBaseMain.db.database;
    var raw = await db.insert('Customer', _customer.toBD());
    return raw;
  }

  static Future<int> updateCustomer(Customer _customer) async {
    final db = await DataBaseMain.db.database;
    var raw = await db.update('Customer', _customer.toBD(),
        where: "customerId = ?", whereArgs: [_customer.customerId]);
    return raw;
  }

  static Future<int> deleteCustomer(Customer _customer) async {
    final db = await DataBaseMain.db.database;
    var raw = await db.delete('Customer',
        where: 'customerId = ${_customer.customerId}');
    return raw;
  }

  // #endregio
  Future<int> insertAktivitasReminder(Aktivitas aktivitas) async {
    final db = await database;
    var raw = await db.rawInsert("""INSERT Into Aktivitas (
      aktivitasName,
      description,
      timeStart,
      timeEnd,
      dateTime,
      notifikasi,
      isAlarm,
      type,
      categoryId,
      customerId,
      isStatus)
         VALUES (?,?,?,?,?,?,?,?,?,?,?)""", [
      aktivitas.aktivitasName,
      aktivitas.description,
      TimeValidator.getHora(aktivitas.timeStart),
      TimeValidator.getHora(aktivitas.timeFinish),
      aktivitas.dateTime,
      aktivitas.notifikasi,
      aktivitas.isAlarm,
      aktivitas.aktivitasType,
      aktivitas.categoryId,
      aktivitas.customerId,
      aktivitas.isStatus
    ]);
    return raw;
  }

  Future<List<Aktivitas>> getAktivitas() async {
    final db = await database;

    var res = await db.rawQuery(SQL.queryAktivitas + ' order by dateTime Desc');
    List<Aktivitas> list =
        res.isNotEmpty ? res.map((c) => Aktivitas.fromBD(c)).toList() : [];
    for (var i = 0; i < list.length; i++) {
      final _category = await obtenerCategorybyID(list[i].categoryId);
      final _customer = await obtenerCustomerbyID(list[i].customerId);
      list[i].color = _category.color;
      list[i].categoryName = _category.categoryName;
      list[i].customerName = _customer.customerName;
    }

    return list;
  }

  // Future<List<Aktivitas>> getAktivitasesByWeekDay(String dateTime) async {
  //   final db = await database;
  //   var res = await db
  //       .rawQuery("SELECT * FROM Aktivitas WHERE dateTime = '$dateTime'");
  //   List<Aktivitas> list =
  //       res.isNotEmpty ? res.map((c) => Aktivitas.fromBD(c)).toList() : [];
  //   for (var i = 0; i < list.length; i++) {
  //     final _category = await obtenerCategorybyID(list[i].categoryId);
  //     final _customer = await obtenerCustomerbyID(list[i].customerId);
  //     list[i].color = _category.color;
  //     list[i].categoryName = _category.categoryName;
  //     list[i].customerName = _customer.customerName;
  //   }
  //   return list;
  // }

  Future<List<Aktivitas>> getAktivitasesByCategoryID(int categoryId) async {
    final db = await database;
    var res = await db
        .rawQuery(SQL.queryAktivitas + " WHERE categoryId = ? ", [categoryId]);
    List<Aktivitas> list =
        res.isNotEmpty ? res.map((c) => Aktivitas.fromBD(c)).toList() : [];
    for (var i = 0; i < list.length; i++) {
      final _category = await obtenerCategorybyID(list[i].categoryId);
      final _customer = await obtenerCustomerbyID(list[i].customerId);
      list[i].color = _category.color;
      list[i].categoryName = _category.categoryName;
      list[i].customerName = _customer.customerName;
    }
    return list;
  }

  Future<List<Aktivitas>> getAktivitasesByCustomerID(int customerId) async {
    final db = await database;
    var res = await db
        .rawQuery(SQL.queryAktivitas + " WHERE customerId = ? ", [customerId]);
    List<Aktivitas> list =
        res.isNotEmpty ? res.map((c) => Aktivitas.fromBD(c)).toList() : [];
    return list;
  }

  Future<List<Aktivitas>> getAktivitasesByAktivitasID(int aktivitasId) async {
    final db = await database;
    var res = await db.rawQuery(
        SQL.queryAktivitas + " WHERE aktivitasId = ? ", [aktivitasId]);
    List<Aktivitas> list =
        res.isNotEmpty ? res.map((c) => Aktivitas.fromBD(c)).toList() : [];
    return list;
  }

  Future<List<Customer>> getCustomer() async {
    final db = await database;
    var res = await db.rawQuery('SELECT * FROM Customer');
    List<Customer> list =
        res.isNotEmpty ? res.map((c) => Customer.fromJson(c)).toList() : [];

    return list;
  }

  Future<List<Setting>> getListSys() async {
    final db = await database;
    List<Setting> list = [];
    List<Map<String, dynamic>> dblist =
        await db.rawQuery('SELECT * FROM Setting');

    for (Map<String, dynamic> item in dblist) {
      list.add(Setting.fromJson(item));
    }
    return list;
  }

  Future<int> updateSys(String colName, String colvalue) async {
    final db = await database;
    return await db
        .rawUpdate("update Setting set $colName = ? ", ["$colvalue"]);
  }

  // Insert Operation: Insert a Note object to database
  Future<int> insertSys(Setting setting) async {
    final db = await database;
    var result = await db.insert("Setting", setting.toBD());
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteSetting() async {
    final db = await database;
    var result = await db.rawDelete('DELETE FROM Setting');
    return result;
  }

  // Get number of Note objects in database
  Future<int> getCount() async {
    final db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from Setting');
    int result = Sqflite.firstIntValue(x);
    return result;
  }
}
