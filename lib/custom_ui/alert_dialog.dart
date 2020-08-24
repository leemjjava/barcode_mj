import 'package:barcode_mj/custom_ui/text_field.dart';
import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'button.dart';

typedef ShowReadDocSnackBar = void Function(String title);
typedef ChangeLocalItem = void Function(bool isDelete);

class ProductInsertDialog extends StatefulWidget{
  ProductInsertDialog({
    Key key,
    this.barcode,
    this.showReadDocSnackBar,
    this.refreshList
  }):super(key:key);

  final String barcode;
  final ShowReadDocSnackBar showReadDocSnackBar;
  final VoidCallback refreshList;

  @override
  ProductInsertDialogState createState()=>ProductInsertDialogState();

}

class ProductInsertDialogState extends State<ProductInsertDialog>{
  TextEditingController _nameCon = TextEditingController();
  TextEditingController _priceCon = TextEditingController();
  TextEditingController _barcodeCon = TextEditingController();
  TextEditingController _countCon = TextEditingController();
  double inputHeight = 40, inputFontSize = 15;

  String category = inputCategoryList[0];

  @override
  void dispose() {
    _nameCon.dispose();
    _priceCon.dispose();
    _barcodeCon.dispose();
    _countCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        contentPadding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
        content: Container(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  alertText('상품등록', 20),
                  SizedBox(height: 20,),
                  Container(
                    alignment: Alignment.center,
                    height: 50,
                    child: Text(widget.barcode,),
                  ),
                  SizedBox(height: 10,),
                  getNameTf(),
                  SizedBox(height: 10,),
                  getPriceTf(),
                  SizedBox(height: 10,),
                  getCountTf(),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      alertBtn('취소', () {
                        textControllerClear();
                        Navigator.pop(context);
                      }),
                      alertBtn('입력', () {
                        createDoc();
                      }),
                    ],
                  ),
                ],
              ),
            )
        )
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

  void createDoc() {
    final name = _nameCon.text;
    final price = _priceCon.text;
    String count = _countCon.text.isEmpty ? "": _countCon.text;

    String message;
    if(widget.barcode == null) message = "바코드를 입력하세요.";
    if(_nameCon.text.isEmpty) message = "상품명을 입력하세요.";
    if(_priceCon.text.isEmpty) message = "상품가격을 입력하세요.";

    if(message != null) widget.showReadDocSnackBar(message);

    FirebaseFirestore.instance.collection(colName).add({
      fnBarcode: widget.barcode,
      fnName: name,
      fnPrice: price,
      fnCount: count,
      fnDatetime: Timestamp.now(),
      fnIsInput: 'N',
      fnCategory: category,
    }).then((value) {
      textControllerClear();
      widget.showReadDocSnackBar('전송완료');
      widget.refreshList();

      textControllerClear();
      Navigator.pop(context);
    }, onError:(error, stacktrace){
      print("$error");
      print(stacktrace.toString());
      showAlert(context ,stacktrace.toString());
    });
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

  textControllerClear(){
    category = inputCategoryList[0];
    _nameCon.clear();
    _priceCon.clear();
    _barcodeCon.clear();
    _countCon.clear();
  }
}

class ProductUpdateDialog extends StatefulWidget{
  ProductUpdateDialog({
    Key key,
    this.showReadDocSnackBar,
    this.changeLocalItem,
    this.doc
  }):super(key:key);

  final ShowReadDocSnackBar showReadDocSnackBar;
  final ChangeLocalItem changeLocalItem;
  final DocumentSnapshot doc;

  @override
  ProductUpdateDialogState createState()=>ProductUpdateDialogState();

}

class ProductUpdateDialogState extends State<ProductUpdateDialog>{
  TextEditingController _nameCon = TextEditingController();
  TextEditingController _priceCon = TextEditingController();
  TextEditingController _barcodeCon = TextEditingController();
  TextEditingController _countCon = TextEditingController();
  double inputHeight = 40, inputFontSize = 15;

  String category;

  @override
  void dispose() {
    _nameCon.dispose();
    _priceCon.dispose();
    _barcodeCon.dispose();
    _countCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemMap = widget.doc.data();
    _nameCon.text = itemMap[fnName];
    _priceCon.text = itemMap[fnPrice];
    _barcodeCon.text = itemMap[fnBarcode];
    _countCon.text = itemMap[fnCount] ?? '';
    if(category == null) category = itemMap[fnCategory] ?? inputCategoryList[0];

    return AlertDialog(
      contentPadding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
      content: Container(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                alertText('상품수정', 20),
                SizedBox(height: 20,),
                alertText('상품명', 15),
                getNameTf(),
                SizedBox(height: 10,),
                alertText('가격', 15),
                getPriceTf(),
                SizedBox(height: 10,),
                alertText('바코드', 15),
                getBarcodeTf(),
                SizedBox(height: 10,),
                alertText('수량', 15),
                getCountTf(),
                SizedBox(height: 10,),
                DropDownBtnCS(
                  value: category,
                  hint: "분류",
                  itemList: inputCategoryList,
                  onChanged: (value){
                    category = value;
                    setState(() {});
                  },
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    alertBtn('취소', ()=> Navigator.pop(context)),
                    alertBtn('수정', ()=> updateDoc(widget.doc.id)),
                    alertBtn('삭제', ()=> deleteDoc(widget.doc.id)),
                  ],
                ),
              ],
            ),
          )
      ),
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


  void deleteDoc(String docID) {
    FirebaseFirestore.instance..collection(colName).doc(docID).delete().then((value){
      widget.changeLocalItem(true);
      Navigator.pop(context);
    },onError:(error, stacktrace){
      print("$error");
      print(stacktrace.toString());

      showAlert(context,'$error : ${stacktrace.toString()}');
    });
  }

  void updateDoc(String docID) {
    final name = _nameCon.text;
    final price = _priceCon.text;
    final barcode = _barcodeCon.text;
    final count = _countCon.text.isEmpty ? "" : _countCon.text;

    String message;
    if(barcode.isEmpty) message = "바코드 데이터가 없습니다.";
    if(price.isEmpty) message = "가격 데이터가 없습니다.";
    if(name.isEmpty) message = "이름 데이터가 없습니다.";

    if(message != null) {
      widget.showReadDocSnackBar(message);
      Navigator.pop(context);
      return;
    }

    FirebaseFirestore.instance..collection(colName).doc(docID).update({
      fnBarcode: barcode,
      fnName: name,
      fnPrice: price,
      fnCount: count,
      fnCategory: category,
    }).then((value){
      widget.changeLocalItem(false);
      textControllerClear();
      Navigator.pop(context);
    },onError:(error, stacktrace){
      print("$error");
      print(stacktrace.toString());

      showAlert(context,'$error : ${stacktrace.toString()}');
    });
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

  textControllerClear(){
    category = inputCategoryList[0];
    _nameCon.clear();
    _priceCon.clear();
    _barcodeCon.clear();
    _countCon.clear();
  }
}