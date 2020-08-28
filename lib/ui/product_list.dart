import 'dart:async';
import 'dart:io';
import 'package:barcode_mj/bloc/product_bloc.dart';
import 'package:barcode_mj/db/db_helper.dart';
import 'package:barcode_mj/ui/product_view.dart';
import 'package:barcode_mj/provider/product_provider.dart';
import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../custom_ui/alert_dialog.dart';
import '../custom_ui/button.dart';
import '../custom_ui/layout.dart';
import '../custom_ui/text_field.dart';

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
  Color topBarColor;
  Timestamp startTimeStamp;
  final bloc = ProductBloc();

  FirebaseFirestore firestore;
  List<DocumentSnapshot> _documents;
  @override
  void initState() {
    super.initState();

    firestore = FirebaseFirestore.instance;
    startTimeStamp = Timestamp.now();

    if(widget.type == productListTypeInput){
      topTitle = '입력 상품';
      topBarColor = Colors.blue;
    } else if(widget.type == productListTypeNotInput){
      topTitle = '미 입력 상품';
      topBarColor = Colors.red;
    } else{
      topTitle = '전체 상품';
      topBarColor = quickBlue69;
    }

    getList();
  }

  void getList() async{
    try{
      List<DocumentSnapshot> documents;

      if(widget.type == productListTypeInput) documents = await bloc.getInputProduct(startTimeStamp);
      else if(widget.type == productListTypeNotInput) documents = await bloc.getNotInputProduct(startTimeStamp);
      else documents = await bloc.getAllProduct(startTimeStamp);

      if(_documents == null) _documents = [];

      if( _documents.length == 0) refreshController.refreshCompleted();
      else refreshController.loadComplete();

      if(documents.isEmpty == false){
        final lastDocuments = documents[documents.length -1];
        startTimeStamp = lastDocuments.data()[fnDatetime];
        _documents.addAll(documents);
      }

      setState(() {});

    }catch(error, stacktrace){
      print("$error");
      print(stacktrace.toString());

      showAlert(context,'$error : ${stacktrace.toString()}');
    }
  }

  @override
  void dispose() {
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
              background: topBarColor,
              textColor: Colors.white,
              onRefresh: (){
                refreshController.requestRefresh(duration: const Duration(milliseconds: 100));
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
      onLoading: ()=>getList(),
      child: listView(),
    );
  }

  refreshList(){
    startTimeStamp = Timestamp.now();
    _documents = null;
    getList();
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
          onLongPress: ()=> showProductView(document.id),
        );
      },
    );
  }

  Widget getFloatingBtn(){
    if(widget.type == productListTypeInput) return Container();

    return FloatingActionButton(
      heroTag: widget.type,
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

      if(checkDocuments.isEmpty) checkLocalBarcode();
      else showProductView(checkDocuments[0].id);

    }, onError: (error, stacktrace){
      print("onError: $error");
      print(stacktrace.toString());
      showAlert(context,stacktrace.toString());
    });
  }

  void checkLocalBarcode(){
    DBHelper().selectByBarcode(barcode.trim()).then((List<Map> products){
      if(products.isEmpty) return showCreateDocDialog();
      final product = products[0];

      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return ProductInsertDialog(
            barcode: barcode,
            showReadDocSnackBar:showReadDocSnackBar,
            refreshList:refreshList,
            localData: product,
          );
        },
      );

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
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context){
          return ProductUpdateDialog(
            showReadDocSnackBar: showReadDocSnackBar,
            doc: doc,
            changeLocalItem: (isDelete){
              changeLocalItem(index,isDelete: isDelete);
            },
          );
        },
    );
  }

  void changeLocalItem(int index,{bool isDelete}) async {
    final document = _documents[index];
    _documents.removeAt(index);

    if(isDelete == true) return showDeleteSnackBar(document.data()[fnName]);

    final newDocument = await getDocument(document.id);
    setState((){
      if(index == _documents.length -1)_documents.add(newDocument);
      _documents.insert(index, newDocument);
      showReadDocSnackBar('${document.data()[fnName]} 수정');
    });
  }

  void showDeleteSnackBar(String name){
    setState(() {
      showReadDocSnackBar('$name 삭제');
    });
  }

  Future<DocumentSnapshot> getDocument(String docID) {
    return firestore
        .collection(colName)
        .doc(docID)
        .get();
  }

  Future<bool> updateIsInput(String docId, String inputType) async{
    try{
      await firestore
          .collection(colName)
          .doc(docId)
          .update({fnIsInput: inputType});

      return true;
    }catch(error, stacktrace){
      print("$error");
      print(stacktrace.toString());

      showAlert(context,'$error : ${stacktrace.toString()}');
    }

    return false;
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

  void showCreateDocDialog(){
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProductInsertDialog(
          barcode: barcode,
          showReadDocSnackBar:showReadDocSnackBar,
          refreshList:refreshList,
        );
      },
    );
  }
}