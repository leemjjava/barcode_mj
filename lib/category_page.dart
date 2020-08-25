import 'package:barcode_mj/custom_ui/layout.dart';
import 'package:barcode_mj/product_view.dart';
import 'package:barcode_mj/provider/product_provider.dart';
import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'custom_ui/alert_dialog.dart';

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
  FirebaseFirestore firestore;
  String topTitle;
  List<DocumentSnapshot> _documents;

  @override
  void initState() {
    super.initState();
    topTitle = widget.category;
    firestore = FirebaseFirestore.instance;
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