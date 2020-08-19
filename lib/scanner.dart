import 'package:barcode_mj/util/util.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'firestore_first_demo.dart';

class Scanner extends StatefulWidget{
  @override
  ScannerState createState() => ScannerState();
}

class ScannerState extends State<Scanner>{
  String barcode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('바코드를 스캔하자'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Container(
                child: RaisedButton(
                  onPressed: barcodeScanning,
                  child: Text("스캔",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  color: Colors.green,
                ),
                padding: const EdgeInsets.all(10.0),
                margin: EdgeInsets.all(10),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
              ),
              Text("바코드를 가져와라",
                style: TextStyle(fontSize: 20),
              ),
              Text(barcode,
                style: TextStyle(fontSize: 25, color:Colors.green),
              ),
              Container(
                child: RaisedButton(
                  onPressed: ()=> Navigator.push(context, createSlideUpRoute(widget : FirestoreFirstDemo())),
                  child: Text("DB",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  color: Colors.green,
                ),
                padding: const EdgeInsets.all(10.0),
                margin: EdgeInsets.all(10),
              ),
            ],
          ),
        )
    );
  }


  //scan barcode asynchronously
  Future barcodeScanning() async {
    final barcode = await BarcodeScanner.scan();

    switch(barcode.type){
      case ResultType.Barcode:
        this.barcode = barcode.rawContent;
        break;
      case ResultType.Cancelled:
        this.barcode = "바코드를 인식해주세요.";
        break;
      case ResultType.Error:
        this.barcode = "에러남.";
        break;
    }

    setState(() {});
  }
}