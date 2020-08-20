import 'dart:async';

import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class SearchList extends StatefulWidget{
  @override
  SearchListState createState()=>SearchListState();

}

class SearchListState extends State<SearchList>{
  String searchKey;
  FirebaseFirestore firestore;
  Stream<QuerySnapshot> _stream;
  List<QueryDocumentSnapshot> _documents = [];
  StreamSubscription<QuerySnapshot> streamSub;

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    _listenStream();
  }

  void setAllStream(){
    _stream = firestore
        .collection(colName)
        .where(fnName, isGreaterThanOrEqualTo: searchKey)
        .where(fnName, isLessThan:  searchKey+'z')
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
  Widget build(BuildContext context) {
    return Container();
  }

}