class SQL {
  static final String queryCustomer = "select * from Customer";
  static final String queryCategory = "select * from category";

  static final String queryAktivitas = "select * from Aktivitas";
  static final String queryAktivitas2 = """SELECT  
    t1.aktivitasId,
    t1.aktivitasName,
     t1.description,
      t1.timeStart,
      t1.timeEnd,
      t1.dateTime,
      t1.notifikasi,
      t1.isAlarm,
      t1.type,
      t3.categoryName,
      t3.color,
      t2.customerName,
      t1.isStatus from Aktivitas t1
      LEFT JOIN Customer t2 on (t1.customerId = t2.customerId)
      LEFT JOIN Category t3 on (t1.categoryId = t3.categoryId) """;
}
