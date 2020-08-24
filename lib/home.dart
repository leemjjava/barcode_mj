import 'dart:convert';
import 'dart:io';

import 'package:barcode_mj/category_list.dart';
import 'package:barcode_mj/category_page_view.dart';
import 'package:barcode_mj/product_page_view.dart';
import 'package:barcode_mj/search_list.dart';
import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom_ui/button.dart';
import 'custom_ui/text_field.dart';

class Home extends StatefulWidget{
  @override
  HomeState createState()=> HomeState();
}

class HomeState extends State<Home>{
  TextEditingController _fileNameCon = TextEditingController();
  TextEditingController _emailCon = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String filePath, fileName;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    getEmail();
  }

  void getEmail() async{
    prefs = await SharedPreferences.getInstance();
  }


  @override
  void dispose() {
    _fileNameCon.dispose();
    _emailCon.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: rootPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 10,),
                Text(
                  "세일마트 바코드 등록",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700
                  ),
                ),
                SizedBox(height: 25,),
                serviceItem(
                  icon: Icon(Icons.list, size: 40,),
                  title: "전체 상품",
                  content: "입력/미입력 전체 리스트",
                  onTap: ()=>serviceItemOnTap(productListTypeAll),
                ),
                SizedBox(height: 10,),
                serviceItem(
                  icon: Icon(Icons.assignment_late, size: 40, color: Colors.red,),
                  title: "미입력 상품",
                  content: "포스기에 미등록된 상품 리스트",
                  onTap: ()=>serviceItemOnTap(productListTypeNotInput),
                ),
                SizedBox(height: 10,),
                serviceItem(
                  icon: Icon(Icons.assignment, size: 40, color: Colors.blue),
                  title: "입력 상품",
                  content: "포스기에 등록된 상품 리스트",
                  onTap: ()=>serviceItemOnTap(productListTypeInput),
                ),
                SizedBox(height: 10,),
                serviceItem(
                  icon: Icon(Icons.email, size: 40, color: Colors.green),
                  title: "엑셀 파일 전송",
                  content: "현재 서버 데이터를 CSV 파일로 변환하여 메일로 전송합니다.",
                  onTap: ()=>showFileDialog(),
                ),
                SizedBox(height: 10,),
                serviceItem(
                  icon: Icon(Icons.category, size: 40, color: Colors.pink),
                  title: "카테고리 입력",
                  content: "카테고리를 입력하고 카테고리 별로 목록을 확인합니다.",
                  onTap: ()=>categoryOnTap(),
                ),
                SizedBox(height: 10,),
                serviceItem(
                  icon: Icon(Icons.search, size: 40, color: Colors.orange),
                  title: "검색",
                  content: "상품명으로 상품 목록을 검색합니다.",
                  onTap: ()=>searchOnTap(),
                ),
                SizedBox(height: 10,),
              ],
            ),
          )
        ),
      )
    );
  }

  void serviceItemOnTap(String type){
    Route route = createSlideUpRoute(widget : ProductPageView(type: type,));
    Navigator.push(context, route);
  }

  void categoryOnTap(){
    Route route = createSlideUpRoute(widget : CategoryPageView());
    Navigator.push(context, route);
  }

  void searchOnTap(){
    Route route = createSlideUpRoute(widget : SearchList());
    Navigator.push(context, route);
  }

  Widget serviceItem({
    @required Icon icon,
    @required String title,
    @required String content,
    GestureTapCallback onTap
  }){

    return SizedBox(
      height: 94,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: quickGrayEd,
              spreadRadius: 1,
              blurRadius: 7,
              offset: Offset(0, 0), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),
        child: InkWellCS(
          backgroundColor: Colors.white,
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.only(left: 30),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                icon,
                SizedBox(width: 40,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 18,
                          color: quickBlack2C,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                    SizedBox(height: 9,),
                    SizedBox(
                      width: 180,
                      child: Text(
                        content,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                            fontSize: 14,
                            color: quickGrayA0
                        ),
                      ),
                    )
                  ],
                )
              ],
            )
          ),
        ),
      ),
    );
  }

  void showFileDialog(){
    _emailCon.text = prefs.get('EMAIL');

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context){
        return AlertDialog(
          contentPadding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
          content: Container(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    alertText('파일 전송', 20),
                    SizedBox(height: 20,),
                    getFileNameTf(),
                    SizedBox(height: 20,),
                    getEmailTf(),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        alertBtn('취소', () {
                          Navigator.pop(context);
                        }),
                        alertBtn('생성', () {
                          if(_fileNameCon.text.isEmpty){
                            showReadDocSnackBar('파일 이름을 입력해주세요.');
                            return;
                          }
                          if(_emailCon.text.isEmpty){
                            showReadDocSnackBar('이메일을 입력해주세요.');
                            return;
                          }
                          DateTime now = DateTime.now();
                          String formattedDate = DateFormat('hh_mm').format(now);

                          fileName = '${_fileNameCon.text}_$formattedDate';

                          getCsv();
                          Navigator.pop(context);
                        }),
                      ],
                    ),
                  ],
                ),
              )
          ),
        );
      },
    );
  }

  Widget getFileNameTf(){
    return UnderLineTfCS(
      controller: _fileNameCon,
      textColor: quickBlack00,
      underLineColor: quickBlack0d,
      cursorColor: quickBlack0d,
      hint: '파일명',
      height: 40,
      width: 1.0,
      fontSize: 15,
    );
  }

  Widget getEmailTf(){
    return UnderLineTfCS(
      controller: _emailCon,
      textColor: quickBlack00,
      underLineColor: quickBlack0d,
      cursorColor: quickBlack0d,
      hint: 'email',
      height: 40,
      width: 1.0,
      fontSize: 15,
    );
  }

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory.absolute.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;

    final checkDirectory = await Directory('$path/barcode_mj').exists();
    if(checkDirectory == false) await Directory('$path/barcode_mj').create();
    filePath = '$path/barcode_mj/$fileName.csv';
    print(filePath);
    return File('$path/barcode_mj/$fileName.csv').create();
  }

  getCsv() async {
    var cloud = await getAllProduct();
    if (cloud.docs.isEmpty){
      showReadDocSnackBar("상품이 없습니다.");
      return;
    }

    List<List<dynamic>> rows = [];
    rows.add(["바코드", "상품명", "가격", "재고",]);

    for (final document in cloud.docs) {
      List<dynamic> row = [];

      row.add(document.data()[fnBarcode]);
      row.add(document.data()[fnName]);
      row.add(document.data()[fnPrice]);
      row.add(document.data()[fnCount]);

      rows.add(row);
    }

    File file = await _localFile;
    String csv = const ListToCsvConverter().convert(rows);
    file.writeAsString(csv);

    sendMailAndAttachment();
  }

  Future<QuerySnapshot> getAllProduct() {
    return FirebaseFirestore.instance
        .collection(colName)
        .orderBy(fnDatetime, descending: true)
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

  sendMailAndAttachment() async {
    final emailAddress = _emailCon.text;
    prefs.setString('EMAIL', emailAddress);

    final Email email = Email(
      body: '상품 목록 CSV 파일 전',
      subject: '전송 시간 ${DateTime.now().toString()}',
      recipients: [_emailCon.text],
      isHTML: true,
      attachmentPaths: [filePath],
    );

    await FlutterEmailSender.send(email);
  }
}