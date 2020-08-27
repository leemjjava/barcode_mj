import 'package:barcode_mj/db/db_helper.dart';
import 'package:barcode_mj/ui/home.dart';
import 'package:barcode_mj/provider/local_product_provider.dart';
import 'package:barcode_mj/provider/product_provider.dart';
import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bloc/assets_csv_bloc.dart';
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
  String barcode = "";
  bool isInitComplete;

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
      final productCount = await DBHelper().selectProductCount();
      if(productCount <= 0) await AssetsCsvBloc().loadCSV();

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

