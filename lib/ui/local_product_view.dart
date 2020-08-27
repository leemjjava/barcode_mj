import 'package:barcode_mj/bloc/assets_csv_bloc.dart';
import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../custom_ui/button.dart';
import '../custom_ui/layout.dart';
import '../custom_ui/text_field.dart';

class LocalProductView extends StatefulWidget{
  LocalProductView({
    Key key,
    @required this.product
  }): super(key:key);

  final Map product;

  @override
  LocalProductViewState createState()=>LocalProductViewState();
}

class LocalProductViewState extends State<LocalProductView>{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  double inputHeight = 40, inputFontSize = 15;
  FirebaseFirestore firestore;
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
    final product = widget.product;

    _nameCon.text = product[icName];
    _priceCon.text = product[icPrice];
    _barcodeCon.text = product[icBarcode];
    _countCon.text = product[icCount] ?? '입력 없음';
    category = product[icCategory01] ?? inputCategoryList[0];
    setState(() {});
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

