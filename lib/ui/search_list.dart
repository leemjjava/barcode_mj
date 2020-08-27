import 'dart:async';

import 'package:barcode_mj/ui/product_view.dart';
import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../custom_ui/alert_dialog.dart';
import '../custom_ui/layout.dart';

class SearchList extends StatefulWidget{
  @override
  SearchListState createState()=>SearchListState();

}

class SearchListState extends State<SearchList>{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController searchTec = TextEditingController();
  String searchKey;
  FirebaseFirestore firestore;
  List<QueryDocumentSnapshot> _documents = [];
  StreamSubscription<QuerySnapshot> streamSub;

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;

    searchTec.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: GestureDetector(
          onTap:() => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Column(
            children: [
              searchBar(),
              Expanded(
                child: listView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchBar(){
    return Container(
      padding: rootMidPadding,
      height: 58,
      width: double.infinity,
      alignment: Alignment.center,
      child: TextField(
        controller: searchTec,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "상품 검색",
          hintStyle: TextStyle(color:Color(0xFFA0A0A0)),
        ),
      ),
    );
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
        child: Text("검색어를 입력하세요."),
      );
    }

    return ListView.builder(
        itemCount: _documents.length,
        itemBuilder: (BuildContext context, int index) {
          final document = _documents[index];

          return PriceCard(
            map: document.data(),
            onTap: ()=> showUpdateOrDeleteDocDialog(document, index),
            onCheckTap: ()=> updateIsInput(document, index),
            onLongPress: ()=> showProductView(document.id),
          );
        }
    );
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
          changeLocalItem: (isDelete){},
        );
      },
    );
  }

  void updateIsInput(DocumentSnapshot document, int index) {
    final isInput = document.data()[fnIsInput];
    final inputType = isInput == 'Y' ? 'N' : 'Y';

    firestore.collection(colName).doc(document.id).update({
      fnIsInput: inputType,
    }).then((value){

    },onError:(error, stacktrace){
      print("$error");
      print(stacktrace.toString());

      showAlert(context,'$error : ${stacktrace.toString()}');
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

}