import 'dart:async';

import 'package:barcode_mj/util/resource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  List<DocumentSnapshot> documents;
  StreamSubscription<QuerySnapshot> _subscription;

  void getProducts() async{
    final stream = FirebaseFirestore.instance
        .collection(colName)
        .orderBy(fnDatetime, descending: true)
        .snapshots();

    _subscription = stream.listen((snapshot) {
      documents = snapshot.docs;
      notifyListeners();

    },onError:(error, stacktrace){
      print("$error");
      print(stacktrace.toString());
    });
  }

  void cancelDocumentsStream(){
    _subscription.cancel();
  }

  void updateCategoryAll() async{
    final firebaseDb = FirebaseFirestore.instance;

    final updateDocuments = documents.where((item){
      if(item.data()[fnCategory] == null) return true;
      return false;
    }).toList();

    var batch = firebaseDb.batch();

    int count = 0;
    for (final doc in updateDocuments) {
      batch.update(
        firebaseDb.collection(colName).doc(doc.id),
        {fnCategory: inputCategoryList[0]},
      );

      ++count;
      if (count % 100 == 0) {
        await batch.commit();
        batch = firebaseDb.batch();
      }
    }

    await batch.commit();
    print('update Count : $count');
  }
}
