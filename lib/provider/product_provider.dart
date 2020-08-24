import 'package:barcode_mj/util/resource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  List<DocumentSnapshot> documents;

  void getProducts() async{
    final stream = FirebaseFirestore.instance
        .collection(colName)
        .orderBy(fnDatetime, descending: true)
        .snapshots();

    stream.listen((snapshot) {

      documents = snapshot.docs;
      notifyListeners();

    },onError:(error, stacktrace){
      print("$error");
      print(stacktrace.toString());
    });
  }
}
