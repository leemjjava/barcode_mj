import 'dart:async';

import 'package:barcode_mj/db/db_helper.dart';
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
  List<Map> products = [];

  @override
  void initState() {
    super.initState();

    searchTec.addListener(() async{
      final keyword = searchTec.text;
      if(keyword.isEmpty) products = [];
      else products = await DBHelper().selectByNameKeyword(keyword);

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
    if(products == null){
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
    if(products.length == 0){
      return Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Text("검색어를 입력하세요."),
      );
    }

    return ListView.builder(
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          final product = products[index];

          return LocalPriceCard(
            map: product,
          );
        }
    );
  }
}