import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'custom_ui/button.dart';
import 'custom_ui/layout.dart';
import 'custom_ui/text_field.dart';

class ProductView extends StatefulWidget{
  ProductView({
    Key key,
    @required this.docId
  }): super(key:key);

  final String docId;

  @override
  ProductViewState createState()=>ProductViewState();
}

class ProductViewState extends State<ProductView>{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  double inputHeight = 40, inputFontSize = 15;
  FirebaseFirestore firestore;
  DocumentSnapshot document;
  String category;

  TextEditingController _nameCon = TextEditingController();
  TextEditingController _priceCon = TextEditingController();
  TextEditingController _barcodeCon = TextEditingController();
  TextEditingController _countCon = TextEditingController();

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    category = inputCategoryList[0];
    setDocument();
  }

  void setDocument(){
    firestore.collection(colName).doc(widget.docId).get().then((document){
      this.document = document;
      _nameCon.text = document.data()[fnName];
      _priceCon.text = document.data()[fnPrice];
      _barcodeCon.text = document.data()[fnBarcode];
      _countCon.text = document.data()[fnCount] ?? '입력 없음';
      category = document.data()[fnCategory] ?? inputCategoryList[0];
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    double minHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          body: SingleChildScrollView(
            child:IntrinsicHeight(
              child: Container(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Column(
                  children: <Widget>[
                    TopBar(
                      title: "상품 상세 화면",
                      closeIcon: Icon(Icons.close),
                    ),
                    SizedBox(height: 20,),
                    Padding(
                      padding: rootPadding,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("상품 정보"),
                            SizedBox(height: 30,),
                            inputBox(getNameTf(), "상품명"),
                            SizedBox(height: 20,),
                            inputBox(getPriceTf(), "가격"),
                            SizedBox(height: 20,),
                            inputBox(getBarcodeTf(), "바코드 번호"),
                            SizedBox(height: 20,),
                            inputBox(getCountTf(), "재고"),
                            SizedBox(height: 10,),
                            noticeText('카테고리 분류'),
                            DropDownBtnCS(
                              value: category,
                              hint: "분류",
                              itemList: inputCategoryList,
                              onChanged: (value){
                                category = value;
                                setState(() {});
                              },
                            ),
                            SizedBox(height: 20,),
                            SizedBox(height: 60,),
                          ]
                      ),
                    ),
                    Spacer(),
                    submitBtn(),
                  ],
                ),
              ),
            ),
          )
      )
    );
  }

  Widget inputBox(Widget inputText, String title, {bool isPw = false}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        noticeText(title),
        inputText,
      ],
    );
  }

  Widget noticeText(String content){
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Text(
        content,
        style: TextStyle(
          color: quickGray7b,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget getNameTf(){
    return UnderLineTfCS(
      controller: _nameCon,
      textColor: quickBlack00,
      underLineColor: quickBlack0d,
      cursorColor: quickBlack0d,
      hint: '상품명',
      height: inputHeight,
      width: 1.0,
      fontSize: inputFontSize,
    );
  }

  Widget getPriceTf(){
    return UnderLineTfCS(
      controller: _priceCon,
      textColor: quickBlack00,
      underLineColor: quickBlack0d,
      cursorColor: quickBlack0d,
      hint: '거래금액(원)',
      height: inputHeight,
      width: 1.0,
      fontSize: inputFontSize,
      isWonDigits: true,
    );
  }

  Widget getCountTf(){
    return UnderLineTfCS(
      controller: _countCon,
      textColor: quickBlack00,
      underLineColor: quickBlack0d,
      cursorColor: quickBlack0d,
      hint: '수량',
      height: inputHeight,
      width: 1.0,
      fontSize: inputFontSize,
      isOnlyDigits: true,
    );
  }

  Widget getBarcodeTf(){
    return UnderLineTfCS(
      controller: _barcodeCon,
      textColor: quickBlack00,
      underLineColor: quickBlack0d,
      cursorColor: quickBlack0d,
      hint: '바코드',
      height: inputHeight,
      width: 1.0,
      fontSize: inputFontSize,
    );
  }

  Widget submitBtn(){
    return ExpandBtnCS(
      title: "상품 수정",
      buttonColor: quickBlue20,
      textColor: quickWhiteFF,
      fontSize: 20,
      height: 60,
      radius: 0,
      onPressed: updateDoc,
    );
  }

  void updateDoc(){
    final name = _nameCon.text;
    final price = _priceCon.text;
    final barcode = _barcodeCon.text;
    final count = _countCon.text.isEmpty ? "" : _countCon.text;

    String message;
    if(barcode.isEmpty) message = "바코드 데이터가 없습니다.";
    if(price.isEmpty) message = "가격 데이터가 없습니다.";
    if(name.isEmpty) message = "이름 데이터가 없습니다.";

    if(message != null) {
      showReadDocSnackBar(message);
      return;
    }

    firestore.collection(colName).doc(widget.docId).update({
      fnBarcode: barcode,
      fnName: name,
      fnPrice: price,
      fnCount: count,
      fnCategory: category,
    }).then((value){
      showOkDialog(context: context, message: "수정이 완료되었습니다.", onDismiss: ()=> Navigator.pop(context));
    },onError:(error, stacktrace){
      print("$error");
      print(stacktrace.toString());

      showAlert(context,'$error : ${stacktrace.toString()}');
    });
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

