import 'package:barcode_mj/bloc/product_bloc.dart';
import 'package:barcode_mj/db/db_helper.dart';
import 'package:barcode_mj/ui/home.dart';
import 'package:barcode_mj/provider/local_product_provider.dart';
import 'package:barcode_mj/provider/product_provider.dart';
import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bloc/csv_bloc.dart';
import 'custom_ui/layout.dart';

void main() {
  return runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => LocalProductProvider()),
        ],
        child: MyApp(),
      )
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isInitComplete;
  final db = DBHelper();

  @override
  initState() {
    super.initState();
    initFirebase();
  }

  initFirebase() async{
    try{
      await Firebase.initializeApp();
      initDb();
    }catch(error, stacktrace) {
      print("$error");
      print(stacktrace.toString());

      showAlert(context, '$error : ${stacktrace.toString()}');
    }
  }

  initDb()async{
    try{
      final productCount = await db.selectProductCount();
      if(productCount <= 0) await CsvBloc().loadCSV();

      updateServerInputProducts();
    }catch(error, stacktrace) {
      print("$error");
      print(stacktrace.toString());

      showAlert(context, '$error : ${stacktrace.toString()}');
    }
  }

  updateServerInputProducts() async{
    try{
      final product = await db.selectLastProduct();
      if(product == null) return setComplete();

      final String barcode = product[icBarcode];
      final bloc = ProductBloc();
      var documents = await bloc.getDocumentByBarcode(barcode.trim());

      if(documents == null) return setComplete();
      if(documents.isEmpty) return setComplete();

      final timestamp = documents[0].data()[fnDatetime];
      print('product timestamp: ${timestampToStrDateTime(timestamp)}');
      documents  = await bloc.getInputProductAll(timestamp);

      final productList = documents.map((item) => item.data()).toList();
      print('product count: ${productList.length}');
      await db.insertServerProductAll(productList);

      setComplete();
    }catch(error, stacktrace) {
      print("$error");
      print(stacktrace.toString());

      showAlert(context, '$error : ${stacktrace.toString()}');
    }

  }

  setComplete(){
    isInitComplete = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: getHome(),
    );
  }

  getHome(){
    if(isInitComplete == true) return Home();
    return SafeArea(
      child: Scaffold(
        body: Center(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('데이터 저장 중 종료하지 마세요.',
                overflow: TextOverflow.clip,
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 30,),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(100),
                child: LinearProgressIndicator(
                  minHeight: 5,
                ),
              )
            ],
          )
        ),
      ),
    );
  }

}

class TextPage extends StatelessWidget{
  final String title, content;

  TextPage({
    Key key,
    @required this.title,
    @required this.content,
  }): super(key:key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: quickWhiteFF,
        body: SingleChildScrollView(
            child: Container(
              padding: rootPadding,
              child: Column(
                children: <Widget>[
                  TopBar(title: title,),
                  Text(content,
                    style: TextStyle(
                        fontSize: 18
                    ),
                  ),
                ],
              ),
            )
        ),
      ),
    );
  }

}

