import 'dart:async';

import 'package:barcode_mj/db/db_helper.dart';
import 'package:barcode_mj/util/resource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LocalProductProvider with ChangeNotifier {
  List<Map> localProduct;

  Future<void> getProducts() async{
    localProduct = await DBHelper().selectAllProduct();
    notifyListeners();
  }

  Future<void> updateCategory(Map<String, dynamic> item, String category) async{
    await DBHelper().updateCategory(item, category);
    getProducts();
  }
}
