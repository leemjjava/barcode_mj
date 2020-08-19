import 'dart:async';
import 'dart:io';

import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'custom_ui/button.dart';
import 'custom_ui/layout.dart';

class ProductList extends StatefulWidget {
  @override
  ProductListState createState()=>ProductListState();
}

class ProductListState extends State<ProductList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String barcode;

  FirebaseFirestore firestore;
  Stream<QuerySnapshot> _stream;
  List<QueryDocumentSnapshot> _documents = [];
  StreamSubscription<QuerySnapshot> streamSub;

  TextEditingController _undNameCon = TextEditingController();
  TextEditingController _undPrice = TextEditingController();
  TextEditingController _undBarcode = TextEditingController();
  TextEditingController _nameCon = TextEditingController();
  TextEditingController _priceCon = TextEditingController();

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    _stream = firestore
        .collection(colName)
        .orderBy(fnDatetime, descending: true)
        .snapshots();

    _listenStream();
  }


  @override
  void dispose() {
    streamSub.cancel();
    super.dispose();
  }
  void _listenStream(){
    streamSub = _stream.listen((snapshot) {
      _documents = snapshot.docs;
      setState(() {});

    },onError:(error, stacktrace){
      print("onError: $error");
      print(stacktrace.toString());
      showAlert(context,stacktrace.toString());
    });
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: quickGrayC9,
        body: Column(
          children: [
            TopBar(
              title: "상품 등록 현황",
              background: quickBlue69,
              textColor: Colors.white,
              onTap: (){
                exit(0);
              },
            ),
            Expanded(
              child: lawyerListView(),
            ),
            Container(
              padding: EdgeInsets.only(left: 5, right: 5),
              child: BorderBtnCS(
                title: '스캔',
                height: 50,
                fontSize: 20,
                radius: 5,
                fontWeight: FontWeight.w800,
                onPressed: barcodeScanning,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget lawyerListView(){
    return ListView.builder(
      itemCount: _documents.length,
      itemBuilder: (BuildContext context, int index) {
        return listItemView(_documents[index]);
      },
    );
  }

  Widget listItemView(DocumentSnapshot document){
    final itemMap = document.data();
    Timestamp ts = itemMap[fnDatetime];
    String dt = timestampToStrDateTime(ts);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: ()=> showUpdateOrDeleteDocDialog(document),
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                height: 50,
                child: Text('${itemMap[fnName]}',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              descriptionWidget('값', 15),
              descriptionWidget('${itemMap[fnPrice]}', 25),
              descriptionWidget('바코드', 15),
              descriptionWidget('${itemMap[fnBarcode]}', 25),
              Text(
                dt,
                style:
                TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget descriptionWidget(String content, double size){
    return Text(
      content,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
        fontSize: size,
        color: quickBlack03,
      ),
    );
  }

  void updateDoc(String docID, String barcode ,String name, String price) {
    firestore.collection(colName).doc(docID).update({
      fnBarcode: barcode,
      fnName: name,
      fnPrice: price,
    });
  }

  void deleteDoc(String docID) {
    firestore.collection(colName).doc(docID).delete();
  }

  void showUpdateOrDeleteDocDialog(DocumentSnapshot doc) {
    final itemMap = doc.data();
    _undNameCon.text = itemMap[fnName];
    _undPrice.text = itemMap[fnPrice];
    _undBarcode.text = itemMap[fnBarcode];

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("상품 수정"),
          content: Container(
            height: 200,
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: "상품명"),
                  controller: _undNameCon,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "가격"),
                  controller: _undPrice,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "바코드"),
                  controller: _undBarcode,
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("취소"),
              onPressed: () {
                _undNameCon.clear();
                _undPrice.clear();
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("수정"),
              onPressed: () {
                if (_undNameCon.text.isNotEmpty && _undPrice.text.isNotEmpty && _undBarcode.text.isNotEmpty) {
                  updateDoc(doc.id, _undNameCon.text, _undPrice.text, _undBarcode.text);
                }
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("삭제"),
              onPressed: () {
                deleteDoc(doc.id);
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  String timestampToStrDateTime(Timestamp ts) {
    return DateTime
        .fromMicrosecondsSinceEpoch(ts.microsecondsSinceEpoch)
        .toString();
  }

  //scan barcode asynchronously
  Future barcodeScanning() async {
    final barcode = await BarcodeScanner.scan();

    switch(barcode.type){
      case ResultType.Barcode:
        this.barcode = barcode.rawContent;
        showCreateDocDialog();
        break;
      case ResultType.Cancelled:
        this.barcode = "바코드를 인식해주세요.";
        break;
      case ResultType.Error:
        this.barcode = "에러남.";
        break;
    }

    setState(() {});
  }

  void checkBarcodeCreate(String name, String price){
    firestore.collection(colName).where(fnBarcode, isEqualTo: barcode).get().then((value){
      List<QueryDocumentSnapshot> _documents = value.docs;

      if(_documents.isEmpty) createDoc(name, price);
      else showAlert(context, '동일한 상품이 존재합니다.');

      for(final item in _documents){
        print('${item.data()[fnName]}');
      }

    }, onError: (error, stacktrace){
      print("onError: $error");
      print(stacktrace.toString());
      showAlert(context,stacktrace.toString());
    });
  }

  void createDoc(String name, String price) {
    firestore.collection(colName).add({
      fnBarcode: barcode,
      fnName: name,
      fnPrice: price,
      fnDatetime: Timestamp.now(),
    }).then((value) {
      barcode = null;
      showReadDocSnackBar('전송완료');
    }, onError:(error, stacktrace){
      print("$error");
      print(stacktrace.toString());
      showAlert(context ,stacktrace.toString());
    });
  }

  void showReadDocSnackBar(String title) {
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.deepOrangeAccent,
          duration: Duration(seconds: 5),
          content: Text(title),
          action: SnackBarAction(
            label: "Done",
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
  }

  void showCreateDocDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('상품 등록'),
          content: Container(
            height: 200,
            child: Column(
              children: <Widget>[
                Text(barcode,),
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(labelText: '상품명'),
                  controller: _nameCon,
                ),
                TextField(
                  decoration: InputDecoration(labelText: '가격'),
                  controller: _priceCon,
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                _nameCon.clear();
                _priceCon.clear();
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Create"),
              onPressed: () {
                String message;
                if(barcode == null) message = "바코드를 입력하세요.";
                if(_nameCon.text.isNotEmpty) message = "상품명을 입력하세요.";
                if(_priceCon.text.isNotEmpty) message = "상품가격을 입력하세요.";

                if(message == null) showReadDocSnackBar(message);
                else checkBarcodeCreate(_nameCon.text, _priceCon.text);

                _nameCon.clear();
                _priceCon.clear();
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}