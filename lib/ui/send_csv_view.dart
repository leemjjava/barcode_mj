import 'dart:io';
import 'package:barcode_mj/bloc/csv_bloc.dart';
import 'package:barcode_mj/bloc/product_bloc.dart';
import 'package:barcode_mj/db/db_helper.dart';
import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../custom_ui/button.dart';
import '../custom_ui/layout.dart';
import '../custom_ui/text_field.dart';

Future<String> getCsv(List<List<dynamic>> rows){
  return Future((){
    return const ListToCsvConverter().convert(rows);
  });
}

class SendCsvView extends StatefulWidget{
  @override
  SendCsvViewState createState()=>SendCsvViewState();
}

class SendCsvViewState extends State<SendCsvView>{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String filePath, fileName;
  SharedPreferences prefs;

  TextEditingController _fileNameCon = TextEditingController();
  TextEditingController _emailCon = TextEditingController();
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    getEmail();
  }
  void getEmail() async{
    prefs = await SharedPreferences.getInstance();
    _emailCon.text = await prefs.get('EMAIL');
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
                    title: "CVS 파일 전송",
                    background: Colors.green,
                    textColor: Colors.white,
                    closeIcon: Icon(Icons.close, color: Colors.white,),
                  ),
                  SizedBox(height: 20,),
                  Padding(
                    padding: rootPadding,
                    child: Column(
                      children: <Widget>[
                        inputBox(getFileNameTf(), '파일명'),
                        SizedBox(height: 20,),
                        inputBox(getEmailTf(), '이메일'),
                        SizedBox(height: 20,),
                      ],
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

  Widget submitBtn(){
    return ExpandBtnCS(
      title: "파일 생성",
      buttonColor: quickBlue20,
      textColor: quickWhiteFF,
      fontSize: 20,
      height: 60,
      radius: 0,
      onPressed: () async{
        String message;
        if(_fileNameCon.text.isEmpty) showReadDocSnackBar('파일 이름을 입력해주세요.');
        if(_emailCon.text.isEmpty) message = '이메일을 입력해주세요.';
        if(message != null) return showReadDocSnackBar(message);

        DateTime now = DateTime.now();
        String formattedDate = DateFormat('hh_mm').format(now);

        fileName = '${_fileNameCon.text}_$formattedDate';

        _progressDialog = getProgressDialog(context, 'Local DB CSV 파일로 만드는 중...');
        _progressDialog.show();

        await getLocalCsv();

        sendMailAndAttachment(filePath);
        _progressDialog.dismiss();
      },
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

  Future<bool> addServerData() async {
    final bloc = ProductBloc();

    final documents = await bloc.getCsvProduct();
    if (documents == null || documents.isEmpty){
      showReadDocSnackBar("상품이 없습니다.");
      return false;
    }

    final productList = documents.map((item) => item.data()).toList();
    await DBHelper().insertServerProductAll(productList);
    await bloc.updateIsInputAll(documents);

    return true;
  }

  Future<void> getLocalCsv() async {
    final isOk = await addServerData();
    if(isOk == false){
      _progressDialog.dismiss();
      return;
    }

    final documents = await DBHelper().selectAllProduct();
    print('documents count: ${documents.length}');
    if (documents == null || documents.isEmpty){
      showReadDocSnackBar("상품이 없습니다.");
      return;
    }

    List<List<dynamic>> rows = [];
    rows.add(["대분류명", "중분류명", "상품명", "바코드", "판매금액", "부가세타입", "매입금액", "재고"]);

    for (final document in documents) {
      List<dynamic> row = [];

      row.add(document[icCategory01]);
      row.add(document[icCategory02]);
      row.add(document[icName]);
      row.add(document[icBarcode]);
      row.add(document[icPrice]);
      row.add(document[icTexType]);
      row.add(document[icBayPrice]);
      row.add(document[icCount]);

      rows.add(row);
    }

    print('rows count: ${rows.length}');

    File file = await _localFile;
    String csv = await compute(getCsv,rows);
    file.writeAsString(csv);
  }

  sendMailAndAttachment(String filePath) async {
    final emailAddress = _emailCon.text;
    prefs.setString('EMAIL', emailAddress);

    final Email email = Email(
      body: '상품 목록 CSV 파일 전송\n전송 시간 ${DateTime.now().toString()}',
      subject: '상품 목록 CSV 파일',
      recipients: [_emailCon.text],
      isHTML: true,
      attachmentPaths: [filePath],
    );

    await FlutterEmailSender.send(email);
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

