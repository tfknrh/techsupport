import 'package:flutter/material.dart';

class Customer {
  int customerId;
  String customerName;
  String customerDesc;
  String customerLocation;
  String customerGps;
  String customerPic;
  String customerAkses;

  Customer();

  factory Customer.fromJson(Map<String, dynamic> json) {
    Customer e = new Customer();
    e.customerId = json["customerId"];
    e.customerName = json["customerName"];
    e.customerDesc = json["customerDesc"];
    e.customerLocation = json["customerLocation"];
    e.customerGps = json["customerGps"];
    e.customerPic = json["customerPic"];
    e.customerAkses = json["customerAkses"];
    return e;
  }

  Map<String, dynamic> toBD() {
    var map = <String, dynamic>{
      'customerId': this.customerId,
      'customerName': this.customerName,
      'customerDesc': this.customerDesc,
      'customerLocation': this.customerLocation,
      'customerGps': this.customerGps,
      'customerPic': this.customerPic,
      'customerAkses': this.customerAkses
    };
    return map;
  }
}
