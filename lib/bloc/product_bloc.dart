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

  Future<List<DocumentSnapshot>> getInputProductAll(dynamic startTimeStamp) async{
    QuerySnapshot snapshot = await _firestore
        .collection(colName)
        .where(fnIsInput, isEqualTo: 'Y')
        .where(fnDatetime, isGreaterThan: startTimeStamp)
        .orderBy(fnDatetime, descending: false)
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

  Future<DocumentSnapshot> getDocument(String docID) {
    return _firestore
        .collection(colName)
        .doc(docID)
        .get();
  }

  Future<List<DocumentSnapshot>> getDocumentByBarcode(String barcode) async{
    QuerySnapshot snapshot = await _firestore
        .collection(colName)
        .where(fnBarcode, isEqualTo: barcode)
        .limit(1)
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


  Future<List<DocumentSnapshot>> getSearch(String keyword) async{
    QuerySnapshot snapshot = await _firestore
        .collection(colName)
        .where(fnName, isGreaterThanOrEqualTo: keyword)
        .orderBy(fnDatetime, descending: true)
        .limit(10)
        .get();

    return snapshot.docs;
  }

  Future<void> updateIsInputAll(List<DocumentSnapshot> documents) async{
    var batch = _firestore.batch();
    int count = 0;
    for (final doc in documents) {
      batch.update(
        _firestore.collection(colName).doc(doc.id),
        {fnIsInput: 'Y'},
      );

      ++count;
      if (count % 100 == 0) {
        await batch.commit();
        batch = _firestore.batch();
      }
    }

    await batch.commit();
  }
}