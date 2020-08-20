import 'dart:async';
import 'dart:io';
import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_ui/button.dart';
import 'custom_ui/layout.dart';
import 'custom_ui/text_field.dart';

// ignore: must_be_immutable
class ProductList extends StatefulWidget {
  ProductList({
    Key key,
    this.type
  }): super(key : key);
  String type;

  @override
  ProductListState createState()=>ProductListState();
}

class ProductListState extends State<ProductList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String barcode, topTitle;

  FirebaseFirestore firestore;
  Stream<QuerySnapshot> _stream;
  List<QueryDocumentSnapshot> _documents = [];
  StreamSubscription<QuerySnapshot> streamSub;

  double inputHeight = 40, inputFontSize = 15;

  TextEditingController _nameCon = TextEditingController();
  TextEditingController _priceCon = TextEditingController();
  TextEditingController _barcodeCon = TextEditingController();
  TextEditingController _countCon = TextEditingController();

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;

    if(widget.type == productListTypeInput) setInputStream();
    else if(widget.type == productListTypeNotInput) setNotInputStream();
    else setAllStream();

    _listenStream();
  }

  void setAllStream(){
    topTitle= "전체 상품 현황";
    _stream = firestore
        .collection(colName)
        .orderBy(fnDatetime, descending: true)
        .snapshots();
  }

  void setInputStream(){
    topTitle= "입력 상품 현황";
    _stream = firestore
        .collection(colName)
        .where(fnIsInput, isEqualTo: 'Y')
        .orderBy(fnDatetime, descending: true)
        .snapshots();
  }

  void setNotInputStream(){
    topTitle= "미입력 상품 현황";
    _stream = firestore
        .collection(colName)
        .where(fnIsInput, isEqualTo: 'N')
        .orderBy(fnDatetime, descending: true)
        .snapshots();
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
  void dispose() {
    streamSub.cancel();
    _nameCon.dispose();
    _priceCon.dispose();
    _barcodeCon.dispose();
    _countCon.dispose();
    super.dispose();
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
              title: topTitle,
              background: quickBlue69,
              textColor: Colors.white,
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

    if(_documents.length == 0){
      return Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Text("데이터가 없습니다."),
      );
    }

    return ListView.builder(
      itemCount: _documents.length,
      itemBuilder: (BuildContext context, int index) {
        final document = _documents[index];

        return PriceCard(
            document: document,
            onTap: ()=> showUpdateOrDeleteDocDialog(document)
        );
      },
    );
  }

  //scan barcode asynchronously
  Future barcodeScanning() async {
    final barcode = await BarcodeScanner.scan();

    switch(barcode.type){
      case ResultType.Barcode:
        this.barcode = barcode.rawContent;
        checkBarcodeCreate();
        break;
      case ResultType.Cancelled:
        this.barcode = null;
        break;
      case ResultType.Error:
        showAlert(context, "BarcodeScanner ResultType.Error");
        break;
    }
  }

  void checkBarcodeCreate(){
    firestore.collection(colName).where(fnBarcode, isEqualTo: barcode).get().then((value){
      List<QueryDocumentSnapshot> _documents = value.docs;

      if(_documents.isEmpty) showCreateDocDialog();
      else showAlert(context, '동일한 상품이 존재합니다.');

    }, onError: (error, stacktrace){
      print("onError: $error");
      print(stacktrace.toString());
      showAlert(context,stacktrace.toString());
    });
  }

  void showUpdateOrDeleteDocDialog(DocumentSnapshot doc) {
    final itemMap = doc.data();
    _nameCon.text = itemMap[fnName];
    _priceCon.text = itemMap[fnPrice];
    _barcodeCon.text = itemMap[fnBarcode];
    _countCon.text = itemMap[fnCount] ?? '';

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
          content: Container(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  alertText('상품수정', 20),
                  SizedBox(height: 20,),
                  alertText('상품명', 15),
                  getNameTf(),
                  SizedBox(height: 10,),
                  alertText('가격', 15),
                  getPriceTf(),
                  SizedBox(height: 10,),
                  alertText('바코드', 15),
                  getBarcodeTf(),
                  SizedBox(height: 10,),
                  alertText('수량', 15),
                  getCountTf(),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      alertBtn('취소', () {
                        textControllerClear();
                        Navigator.pop(context);
                      }),
                      alertBtn('수정', () {
                        updateDoc(doc.id);
                        textControllerClear();
                        Navigator.pop(context);
                      }),
                      alertBtn('삭제', () {
                        deleteDoc(doc.id);
                        textControllerClear();
                        Navigator.pop(context);
                      }),
                    ],
                  ),
                ],
              ),
            )
          ),
        );
      },
    );
  }

  Widget alertText(String title, double size){
    return Text(title,
      style: TextStyle(
          color: quickBlue07,
          fontSize: size
      ),
    );
  }

  Widget alertBtn(String title, VoidCallback onPressed){
    return SizedBox(
      width: 60,
      child: FlatButton(
        child: Text(title,
          style: TextStyle(
            color: quickBlack28
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  void updateDoc(String docID) {
    final name = _nameCon.text;
    final price = _priceCon.text;
    final barcode = _barcodeCon.text;
    final count = _countCon.text.isEmpty ? "" : _countCon.text;

    String message;
    if(barcode.isEmpty) message = "바코드 데이터가 없습니다.";
    if(price.isEmpty) message = "가격 데이터가 없습니다.";
    if(name.isEmpty) message = "이름 데이터가 없습니다.";

    if(message != null) {
      showReadDocSnackBar(message);
      return;
    }

    firestore.collection(colName).doc(docID).update({
      fnBarcode: barcode,
      fnName: name,
      fnPrice: price,
      fnCount: count,
    });
  }

  void deleteDoc(String docID) {
    firestore.collection(colName).doc(docID).delete();
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
          contentPadding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
          content: Container(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  alertText('상품등록', 20),
                  SizedBox(height: 20,),
                  Container(
                    alignment: Alignment.center,
                    height: 50,
                    child: Text(barcode,),
                  ),
                  SizedBox(height: 10,),
                  getNameTf(),
                  SizedBox(height: 10,),
                  getPriceTf(),
                  SizedBox(height: 10,),
                  getCountTf(),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      alertBtn('취소', () {
                        textControllerClear();
                        Navigator.pop(context);
                      }),
                      alertBtn('입력', () {
                        createDoc();
                        textControllerClear();
                        Navigator.pop(context);
                      }),
                    ],
                  ),
                ],
              ),
            )
          ),
        );
      },
    );
  }

  void createDoc() {
    final name = _nameCon.text;
    final price = _priceCon.text;
    String count = _countCon.text.isEmpty ? "": _countCon.text;

    String message;
    if(barcode == null) message = "바코드를 입력하세요.";
    if(_nameCon.text.isEmpty) message = "상품명을 입력하세요.";
    if(_priceCon.text.isEmpty) message = "상품가격을 입력하세요.";

    if(message != null) showReadDocSnackBar(message);

    firestore.collection(colName).add({
      fnBarcode: barcode,
      fnName: name,
      fnPrice: price,
      fnCount: count,
      fnDatetime: Timestamp.now(),
      fnIsInput: 'N'
    }).then((value) {
      barcode = null;
      showReadDocSnackBar('전송완료');
    }, onError:(error, stacktrace){
      print("$error");
      print(stacktrace.toString());
      showAlert(context ,stacktrace.toString());
    });
  }

  Widget getNameTf(){
    return UnderLineTfCS(
      controller: _nameCon,
      textColor: quickBlack00,
      underLineColor: quickBlack0d,
      cursorColor: quickBlack0d,
      hint: '상품명',
      height: inputHeight,
      width: 1.0,
      fontSize: inputFontSize,
    );
  }

  Widget getPriceTf(){
    return UnderLineTfCS(
      controller: _priceCon,
      textColor: quickBlack00,
      underLineColor: quickBlack0d,
      cursorColor: quickBlack0d,
      hint: '거래금액(원)',
      height: inputHeight,
      width: 1.0,
      fontSize: inputFontSize,
      isWonDigits: true,
    );
  }

  Widget getCountTf(){
    return UnderLineTfCS(
      controller: _countCon,
      textColor: quickBlack00,
      underLineColor: quickBlack0d,
      cursorColor: quickBlack0d,
      hint: '수량',
      height: inputHeight,
      width: 1.0,
      fontSize: inputFontSize,
      isOnlyDigits: true,
    );
  }

  Widget getBarcodeTf(){
    return UnderLineTfCS(
      controller: _barcodeCon,
      textColor: quickBlack00,
      underLineColor: quickBlack0d,
      cursorColor: quickBlack0d,
      hint: '바코드',
      height: inputHeight,
      width: 1.0,
      fontSize: inputFontSize,
    );
  }

  textControllerClear(){
    _nameCon.clear();
    _priceCon.clear();
    _barcodeCon.clear();
    _countCon.clear();
  }
}