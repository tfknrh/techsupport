import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:techsupport/models.dart';
import 'package:techsupport/utils.dart';
import 'package:techsupport/api/SQL.dart';
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
             isStatus INTEGER,
             formValue TEXT)""");

    await db.execute("""CREATE TABLE Customer (
      customerId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      customerName TEXT NOT NULL,
      customerDesc TEXT NOT NULL,
      customerLocation TEXT,
       customerGps TEXT,
       customerPic TEXT,
      customerAkses TEXT)""");

    await db.execute("""CREATE TABLE images(
              imgId INTEGER PRIMARY KEY AUTOINCREMENT,
              imgImage TEXT,
              imgName TEXT,
              aktivitasId INTEGER,
              imgStr TEXT,
              isSync INTEGER)""");

    await db.execute("""CREATE TABLE setting (
      sysCountAkt INTEGER,
      sysCountCust INTEGER,
      sysCountImg INTEGER,
      sysBackupSize TEXT,
      sysBackupSch TEXT,
      sysGmail TEXT,
      sysDBId TEXT,
      sysCreated TEXT,  
      sysModified TEXT  
       )""");

    await db.execute("""CREATE TABLE Formulir (
      formId INTEGER,
      formType INTEGER,
      formName TEXT,
      formValue TEXT,
      categoryId INTEGER
      
       )""");

    await db.insert("setting", {
      "sysCountAkt": "0",
      "sysCountCust": "0",
      "sysCountImg": "0",
      "sysBackupSize": "0",
      "sysBackupSch": "2021-01-01 00:00:00",
      "sysGmail": "No Account",
      "sysCreated": "2021-01-01 00:00:00",
      "sysModified": "2021-01-01 00:00:00"
    });
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
        "INSERT INTO Category(categoryName,color,candelete) values('Pengecekan System','fff5722',0)");
    await db.execute(
        "INSERT INTO Category(categoryName,color,candelete) values('Training','ffe91e63',0)");
    await db.execute(
        "INSERT INTO Category(categoryName,color,candelete) values('Lain-lain','ffff9800',0)");
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

  static Future<List<Aktivitas>> getListAktivitass() async {
    final db = await DataBaseMain.db.database;
    final res = await db.query('Aktivitas');
    List<Aktivitas> list =
        res.isNotEmpty ? res.map((c) => Aktivitas.fromBD(c)).toList() : [];
    for (var i = 0; i < list.length; i++) {
      final _category = await getListCategorybyID(list[i].categoryId);
      final _customer = await getListCustomerbyID(list[i].customerId);
      list[i].color = _category.color;
      list[i].categoryName = _category.categoryName;
      list[i].customerName = _customer.customerName;
    }
    return list;
  }

  static Future<Aktivitas> getListAktivitasbyID(int id) async {
    final db = await DataBaseMain.db.database;
    final res =
        await db.rawQuery(SQL.queryAktivitas + ' where aktivitasId = ?', [id]);
    List<Aktivitas> list =
        res.isNotEmpty ? res.map((c) => Aktivitas.fromBD(c)).toList() : [];
    for (var i = 0; i < list.length; i++) {
      final _category = await getListCategorybyID(list[i].categoryId);
      final _customer = await getListCustomerbyID(list[i].customerId);
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
  static Future<List<Category>> getListCategorys() async {
    final db = await DataBaseMain.db.database;
    final res = await db.query('Category');
    List<Category> list =
        res.isNotEmpty ? res.map((c) => Category.fromJson(c)).toList() : [];
    return list;
  }

  static Future<Category> getListCategorybyID(int id) async {
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

//Formulir
  static Future<List<Formulir>> getListFormulirs() async {
    final db = await DataBaseMain.db.database;
    final res = await db.query('Formulir');
    List<Formulir> list =
        res.isNotEmpty ? res.map((c) => Formulir.fromBD(c)).toList() : [];
    return list;
  }

  static Future<Formulir> getListFormulirbyID(int id) async {
    final db = await DataBaseMain.db.database;
    final res =
        await db.rawQuery('select * from Formulir where formId = ?', [id]);
    List<Formulir> list =
        res.isNotEmpty ? res.map((c) => Formulir.fromBD(c)).toList() : [];
    return list.isEmpty ? null : list[0];
  }

  static Future<int> insertFormulir(Formulir _form) async {
    final db = await DataBaseMain.db.database;
    var raw = await db.insert('Formulir', _form.toBD());
    return raw;
  }

  static Future<int> updateFormulir(Formulir _form) async {
    final db = await DataBaseMain.db.database;
    var raw = await db.update('Formulir', _form.toBD(),
        where: "formId = ?", whereArgs: [_form.formId]);
    return raw;
  }

  static Future<int> deleteFormulir(Formulir _form) async {
    final db = await DataBaseMain.db.database;
    var raw = await db.delete('Formulir', where: 'formId = ${_form.formId}');
    return raw;
  }

  // #endregion
  // #region Setting
  Future<List<Setting>> getListSettings() async {
    final db = await DataBaseMain.db.database;
    final res = await db.query('Setting');
    List<Setting> list =
        res.isNotEmpty ? res.map((c) => Setting.fromJson(c)).toList() : [];
    return list;
  }

  static Future<int> insertSetting(Setting _setting) async {
    final db = await DataBaseMain.db.database;
    var raw = await db.insert('Setting', _setting.toBD());
    return raw;
  }

  static Future<int> updateSetting(Setting _setting) async {
    final db = await DataBaseMain.db.database;
    var raw = await db.update(
      'Setting',
      _setting.toBD(),
    );
    return raw;
  }

  static Future<int> deleteSetting(Setting _setting) async {
    final db = await DataBaseMain.db.database;
    var raw = await db.delete('Setting');
    return raw;
  }

  Future<int> getCountSetting() async {
    final db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from Setting');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // #endregion
// #region Customer
  static Future<List<Customer>> getListCustomers() async {
    final db = await DataBaseMain.db.database;
    final res = await db.query('Customer');
    List<Customer> list =
        res.isNotEmpty ? res.map((c) => Customer.fromJson(c)).toList() : [];
    return list;
  }

  static Future<Customer> getListCustomerbyID(int id) async {
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
      TimeValidator.getTime(aktivitas.timeStart),
      TimeValidator.getTime(aktivitas.timeFinish),
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

  Future<int> insetImagesraw(Images _image) async {
    final db = await database;
    var raw = await db.rawInsert("""INSERT Into images (
    imgImage,imgName, aktivitasId)
         VALUES (?,?,?)""",
        [_image.imgImage, _image.imgName, _image.aktivitasId]);
    return raw;
  }

  Future<List<Aktivitas>> getAktivitas() async {
    final db = await database;

    var res = await db.rawQuery(SQL.queryAktivitas + ' order by dateTime Desc');
    List<Aktivitas> list =
        res.isNotEmpty ? res.map((c) => Aktivitas.fromBD(c)).toList() : [];
    for (var i = 0; i < list.length; i++) {
      final _category = await getListCategorybyID(list[i].categoryId);
      final _customer = await getListCustomerbyID(list[i].customerId);
      list[i].color = _category.color;
      list[i].categoryName = _category.categoryName;
      list[i].customerName = _customer.customerName;
    }

    return list;
  }

  Future<List<Aktivitas>> getAktivitasesByCategoryID(int categoryId) async {
    final db = await database;
    var res = await db
        .rawQuery(SQL.queryAktivitas + " WHERE categoryId = ? ", [categoryId]);
    List<Aktivitas> list =
        res.isNotEmpty ? res.map((c) => Aktivitas.fromBD(c)).toList() : [];
    for (var i = 0; i < list.length; i++) {
      final _category = await getListCategorybyID(list[i].categoryId);
      final _customer = await getListCustomerbyID(list[i].customerId);
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

  static Future<List<Formulir>> getFormulirByCategoryID(int categoryId) async {
    final db = await DataBaseMain.db.database;
    var res = await db
        .rawQuery("select * from Formulir WHERE categoryId = ? ", [categoryId]);
    List<Formulir> list =
        res.isNotEmpty ? res.map((c) => Formulir.fromBD(c)).toList() : [];
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

  Future<int> updateAktivitascol(
      String colName, String colvalue, int colId) async {
    final db = await database;
    return await db.rawUpdate(
        "update Aktivitas set $colName = ? where aktivitasId = ?",
        ["$colvalue", "$colId"]);
  }

  Future<int> updateSettingcol(String colName, String colvalue) async {
    final db = await database;
    return await db
        .rawUpdate("update Setting set $colName = ? ", ["$colvalue"]);
  }

  Future<int> updateImagescol(
      String colName, String colvalue, int colId) async {
    final db = await database;
    return await db.rawUpdate("update Images set $colName = ? where imgId = ?",
        ["$colvalue", "$colId"]);
  }

  batchInsertImages(List<Images> _images) async {
    final db = await database;
    var buffer = new StringBuffer();
    _images.forEach((c) {
      if (buffer.isNotEmpty) {
        buffer.write(",\n");
      }
      buffer.write("('");
      buffer.write(c.imgImage);
      buffer.write("', '");
      buffer.write(c.imgName);
      buffer.write("', '");
      buffer.write(c.aktivitasId);
      buffer.write("')");
    });
    var raw =
        await db.rawInsert("INSERT Into Clients (imgImage,imgName,aktivitasId)"
            " VALUES ${buffer.toString()}");
    return raw;
  }

  // Get number of Note objects in database
  Future<int> getCountImages() async {
    List<Map<String, dynamic>> x =
        await _database.rawQuery('SELECT COUNT (*) from images');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> maxAktId() async {
    var _database = await database;
    List<Map<String, dynamic>> x =
        await _database.rawQuery('SELECT max(aktivitasId) from aktivitas');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  static Future<List<Images>> getListImages() async {
    final db = await DataBaseMain.db.database;
    final res = await db.query('Images');
    List<Images> list =
        res.isNotEmpty ? res.map((c) => Images.fromJson(c)).toList() : [];
    // for (var i = 0; i < list.length; i++) {
    //   final _aktivitas = await getListAktivitasbyID(list[i].aktivitasId);

    //   list[i].aktivitasName = _aktivitas.aktivitasName;
    // }
    return list;
  }

  static Future<List<Images>> getListImagesbyAktId(int id) async {
    final db = await DataBaseMain.db.database;
    final res =
        await db.rawQuery('select * from Images where aktivitasId = ?', [id]);

    List<Images> list =
        res.isNotEmpty ? res.map((c) => Images.fromJson(c)).toList() : [];
    return list;
  }

  static Future<Images> getListImagesbyID(int id) async {
    final db = await DataBaseMain.db.database;
    final res = await db.rawQuery('select * from Images where imgId = ?', [id]);
    List<Images> list =
        res.isNotEmpty ? res.map((c) => Images.fromJson(c)).toList() : [];
    return list.isEmpty ? null : list[0];
  }

  static Future<int> insertImages(Images _images) async {
    final db = await DataBaseMain.db.database;
    var raw = await db.insert('Images', _images.toBD());
    return raw;
  }

  static Future<int> updateImages(Images _images) async {
    final db = await DataBaseMain.db.database;
    var raw = await db.update('Images', _images.toBD(),
        where: "imgId = ?", whereArgs: [_images.imgId]);
    return raw;
  }

  static Future<int> deleteImages(Images _images) async {
    final db = await DataBaseMain.db.database;
    var raw = await db.delete('Images', where: 'imgId = ${_images.imgId}');
    return raw;
  }
}
