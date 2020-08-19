import 'package:barcode_mj/scanner.dart';
import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'custom_ui/layout.dart';

void main() {
  return runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String barcode = "";

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:FutureBuilder(
        // Initialize FlutterFire
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return TextPage(title: "문제발생", content: "ERROR");
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return MaterialApp(
              home: Scanner(),
            );
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 5.0,
            )
          );
        },
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

