import 'dart:async';
import 'dart:io';
import 'package:barcode_mj/product_view.dart';
import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'custom_ui/button.dart';
import 'custom_ui/layout.dart';
import 'custom_ui/text_field.dart';

// ignore: must_be_immutable
class ProductList extends StatefulWidget{
  ProductList({
    Key key,
    this.type
  }): super(key : key);
  String type;

  @override
  ProductListState createState()=>ProductListState();
}

class ProductListState extends State<ProductList>{
  RefreshController refreshController = RefreshController(initialRefresh: false);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String barcode, topTitle;
  Timestamp startTimeStamp;

  FirebaseFirestore firestore;
  List<DocumentSnapshot> _documents;

  double inputHeight = 40, inputFontSize = 15;

  TextEditingController _nameCon = TextEditingController();
  TextEditingController _priceCon = TextEditingController();
  TextEditingController _barcodeCon = TextEditingController();
  TextEditingController _countCon = TextEditingController();

  @override
  void initState() {
    super.initState();

    firestore = FirebaseFirestore.instance;
    startTimeStamp = Timestamp.now();
    startGetList();
  }

  void startGetList(){
    Future<QuerySnapshot> snapshotFuture;
    if(widget.type == productListTypeInput) snapshotFuture = setInputStream();
    else if(widget.type == productListTypeNotInput) snapshotFuture = setNotInputStream();
    else snapshotFuture = setAllStream();

    snapshotFuture.then((snapshot){
      if(_documents == null) _documents = [];

      if( _documents.length == 0) refreshController.refreshCompleted();
      else refreshController.loadComplete();

      final documents = snapshot.docs;
      if(documents.isEmpty) return;

      final lastDocuments = documents[snapshot.docs.length -1];
      startTimeStamp = lastDocuments.data()[fnDatetime];

      _documents.addAll(snapshot.docs);

      setState(() {});
    },onError:(error, stacktrace){
      print("$error");
      print(stacktrace.toString());

      showAlert(context,'$error : ${stacktrace.toString()}');
    });
  }



  Future<QuerySnapshot> setAllStream() {
    topTitle= "전체 상품 현황";
    return firestore
        .collection(colName)
        .where(fnDatetime, isLessThan: startTimeStamp)
        .orderBy(fnDatetime, descending: true)
        .limit(10)
        .get();
  }

  Future<QuerySnapshot> setInputStream() async{
    topTitle= "입력 상품 현황";
    return await firestore
        .collection(colName)
        .where(fnIsInput, isEqualTo: 'Y')
        .where(fnDatetime, isLessThan: startTimeStamp)
        .orderBy(fnDatetime, descending: true)
        .limit(10)
        .get();
  }

  Future<QuerySnapshot> setNotInputStream() async{
    topTitle= "미입력 상품 현황";
    return await firestore
        .collection(colName)
        .where(fnIsInput, isEqualTo: 'N')
        .where(fnDatetime, isLessThan: startTimeStamp)
        .orderBy(fnDatetime, descending: true)
        .limit(10)
        .get();
  }

  @override
  void dispose() {
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
        body: Column(
          children: [
            TopRefreshBar(
              title: topTitle,
              background: quickBlue69,
              textColor: Colors.white,
              onRefresh: (){
                refreshController.requestRefresh(duration: const Duration(milliseconds: 100));
                refreshList();
              },
            ),
            Expanded(
              child: refresher(),
            ),
          ],
        ),
        floatingActionButton: getFloatingBtn(),
      ),
    );
  }

  Widget refresher(){
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: ClassicHeader(
        idleText: "당겨서 리프레시",
        completeText: "완료",
        refreshingText: "리프레시 중...",
        releaseText: "새로고침",
      ),
      footer: CustomFooter(
        builder: (BuildContext context,LoadStatus mode){
          Widget body;
          if(mode == LoadStatus.idle) body =  Text("마지막", style: TextStyle(color: quickGrayA8),);
          else if(mode == LoadStatus.loading) body =  CupertinoActivityIndicator();

          return Container(
            height: 55.0,
            child: Center(child:body),
          );
        },
      ),
      controller: refreshController,
      onRefresh: refreshList,
      onLoading: ()=>startGetList(),
      child: listView(),
    );
  }

  refreshList(){
    startTimeStamp = Timestamp.now();
    _documents = null;
    startGetList();
    setState(() {});
  }

  Widget listView(){
    if(_documents == null){
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(100),
        child: LinearProgressIndicator(
          minHeight: 5,
          backgroundColor: Colors.transparent,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      );
    }
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
          map: document.data(),
          onTap: ()=> showUpdateOrDeleteDocDialog(document, index),
          onDelete: ()=> deleteDoc(document.id, index),
          onCheckTap: ()=> updateIsInput(document, index),
          onLongPress: ()=> showProductView(document.id),
        );
      },
    );
  }

  Widget getFloatingBtn(){
    if(widget.type != productListTypeAll) return Container();
    return FloatingActionButton(
      onPressed: barcodeScanning,
      child: Icon(Icons.camera_alt),
      backgroundColor: Colors.blue,
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
      List<DocumentSnapshot> checkDocuments = value.docs;

      if(checkDocuments.isEmpty) showCreateDocDialog();
      else showProductView(checkDocuments[0].id);

    }, onError: (error, stacktrace){
      print("onError: $error");
      print(stacktrace.toString());
      showAlert(context,stacktrace.toString());
    });
  }
  
  void showProductView(String docID){
    Route route = createSlideUpRoute(widget : ProductView(docId: docID,));
    Navigator.push(context, route);
  }

  void showUpdateOrDeleteDocDialog(DocumentSnapshot doc, int index) {
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
                        updateDoc(doc.id, index);
                        textControllerClear();
                        Navigator.pop(context);
                      }),
                      alertBtn('삭제', () {
                        deleteDoc(doc.id, index);
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

  void changeLocalItem(int index,{bool isDelete}) async {
    final document = _documents[index];
    _documents.removeAt(index);
    if(isDelete == true){
      setState(() {});
      return;
    }

    final newDocument = await getDocument(document.id);
    setState((){
      if(index == _documents.length -1)_documents.add(newDocument);
      _documents.insert(index, newDocument);
    });
  }

  Future<DocumentSnapshot> getDocument(String docID) {
    return firestore
        .collection(colName)
        .doc(docID)
        .get();
  }

  void updateDoc(String docID, int index) {
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
    }).then((value){
      changeLocalItem(index);
    },onError:(error, stacktrace){
      print("$error");
      print(stacktrace.toString());

      showAlert(context,'$error : ${stacktrace.toString()}');
    });
  }

  void updateIsInput(DocumentSnapshot document, int index) {
    final isInput = document.data()[fnIsInput];
    final inputType = isInput == 'Y' ? 'N' : 'Y';

    firestore.collection(colName).doc(document.id).update({
      fnIsInput: inputType,
    }).then((value){
      final isTypeAll = widget.type != productListTypeAll;
      changeLocalItem(index, isDelete: isTypeAll);
    },onError:(error, stacktrace){
      print("$error");
      print(stacktrace.toString());

      showAlert(context,'$error : ${stacktrace.toString()}');
    });
  }

  void deleteDoc(String docID, int index) {
    firestore.collection(colName).doc(docID).delete().then((value){
      changeLocalItem(index, isDelete: true);
    },onError:(error, stacktrace){
      print("$error");
      print(stacktrace.toString());

      showAlert(context,'$error : ${stacktrace.toString()}');
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
      refreshList();
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