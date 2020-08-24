import 'package:barcode_mj/custom_ui/layout.dart';
import 'package:barcode_mj/provider/product_provider.dart';
import 'package:barcode_mj/util/resource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CategoryPage extends StatefulWidget{
  CategoryPage({
    Key key,
    this.category,
  }) :super(key:key);

  final String category;

  @override
  CategoryPageState createState()=> CategoryPageState();
}

class CategoryPageState extends State<CategoryPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String topTitle;
  List<DocumentSnapshot> _documents;

  @override
  void initState() {
    super.initState();
    topTitle = widget.category;
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final documents = Provider.of<ProductProvider>(context).documents;

    _documents = documents.where((item){
      if(item.data()[fnCategory] == widget.category) return true;
      return false;
    }).toList();

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Column(
          children: [
            TopBar(
              title: topTitle,
              background: quickBlue69,
              textColor: Colors.white,
            ),
            Expanded(
              child: listView(),
            ),
          ],
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
        child: Text("데이터가 없습니다."),
      );
    }

    return ListView.builder(
        itemCount: _documents.length,
        itemBuilder: (BuildContext context, int index) {
          final document = _documents[index];

          return CategoryCard(
            map: document.data(),
            onTap: (){},
            updateCategory:(category)=>updateCategory(category, document.id),
          );
        }
    );
  }

  void updateCategory(String category, String docId){
    FirebaseFirestore.instance.collection(colName).doc(docId).update({
      fnCategory: category
    });
  }
}