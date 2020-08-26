import 'package:barcode_mj/util/resource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductBloc{
  FirebaseFirestore _firestore;

  ProductBloc(){
    _firestore = FirebaseFirestore.instance;
  }

  Future<List<DocumentSnapshot>> getAllProduct(dynamic startTimeStamp) async{
    QuerySnapshot snapshot = await _firestore
        .collection(colName)
        .where(fnDatetime, isLessThan: startTimeStamp)
        .orderBy(fnDatetime, descending: true)
        .limit(10)
        .get();

    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> getInputProduct(dynamic startTimeStamp) async{
    QuerySnapshot snapshot = await _firestore
        .collection(colName)
        .where(fnIsInput, isEqualTo: 'Y')
        .where(fnDatetime, isLessThan: startTimeStamp)
        .orderBy(fnDatetime, descending: true)
        .limit(10)
        .get();

    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> getNotInputProduct(dynamic startTimeStamp) async{
    QuerySnapshot snapshot = await _firestore
        .collection(colName)
        .where(fnIsInput, isEqualTo: 'N')
        .where(fnDatetime, isLessThan: startTimeStamp)
        .orderBy(fnDatetime, descending: true)
        .limit(10)
        .get();

    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> getCategory(String category ,dynamic startTimeStamp) async{
    QuerySnapshot snapshot = await _firestore
        .collection(colName)
        .where(fnCategory, isEqualTo: category)
        .where(fnDatetime, isLessThan: startTimeStamp)
        .orderBy(fnDatetime, descending: true)
        .limit(10)
        .get();

    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> getCsvProduct() async{
    QuerySnapshot snapshot = await _firestore
        .collection(colName)
        .where(fnIsInput, isEqualTo: 'N')
        .orderBy(fnDatetime, descending: true)
        .get();

    return snapshot.docs;
  }
}