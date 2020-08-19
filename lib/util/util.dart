import 'package:barcode_mj/util/resource.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

int errorMethod(){
  String str = "AAAADDDDBBBB";
  return str as int;
}

EdgeInsets rootPadding = EdgeInsets.only(top:5, left: 20, right: 20);
EdgeInsets rootMidPadding = EdgeInsets.only(left: 20, right: 20);

ProgressDialog getProgressDialog(BuildContext context , String title){
  ProgressDialog pr = new ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: true, showLogs: false);
  pr.style(
    progress: 50.0,
    message: title,
    progressWidget: Container(
        padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
    maxProgress: 100.0,
    progressTextStyle: TextStyle(
        color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
    messageTextStyle: TextStyle(
        color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w600),
  );
  return pr;
}

void showAlert(BuildContext context,String message){
  showAlertDialog(context: context, message: message,);
}

void showAlertDialog({
  BuildContext context,
  String message,
  VoidCallback okPressed,
  VoidCallback cancelPressed,
  Function onDismiss}) async {

  String result = await showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('알림'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.pop(context, "OK");
            },
          ),
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context, "Cancel");
            },
          ),
        ],
      );
    },
  );

  if(result == 'OK' && okPressed != null){
    okPressed();
  }else if(result == 'Cancel' && cancelPressed != null){
    cancelPressed();
  }
}

void showOkDialog({
  BuildContext context,
  String message,
  VoidCallback onDismiss}) async {

  await showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('알림'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.pop(context, "OK");
            },
          ),
        ],
      );
    },
  );

  if(onDismiss != null) onDismiss();
}

Route createSlideUpRoute({Widget widget}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => widget,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

String numberToWon(String number){
  final han1 = ["","일","이","삼","사","오","육","칠","팔","구"];
  final han2 = ["","십","백","천"];
  final han3 = ["","만","억","조","경"];
  StringBuffer stringBuffer = StringBuffer();

  int len = number.length;
  for(int i = len-1; i>=0; i--){
    String item = number.substring(len-i-1, len-i);
    final index = int.parse(item);
    String han1Item = han1[index];

    if(index > 0){
      if(index != 1) stringBuffer.write(han1Item);
      stringBuffer.write(han2[i%4]);
    }else stringBuffer.write(han1Item);
    if(i%4 == 0){
      if(index == 1) stringBuffer.write(han1Item);
      stringBuffer.write(han3[(i/4).round()]);
    }
  }
  stringBuffer.write(" 원");
  String won = stringBuffer.toString();

  won = won.replaceAll("억만", "억");
  won = won.replaceAll("조억", "조");
  won = won.replaceAll("경조", "경");

  return won;
}

bool validateEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  return (!regex.hasMatch(value)) ? false : true;
}

void showBottomPicker({
  BuildContext context,
  List<String> pickerList,
  ValueChanged<int> onSelectedItemChanged,
  GestureTapCallback onTap,
  int initialItem = 0,
}) {
  FixedExtentScrollController controller = FixedExtentScrollController(initialItem: initialItem);

  final picker = CupertinoPicker(
    backgroundColor: Colors.white,
    squeeze: 1.2,
    diameterRatio: 100,
    onSelectedItemChanged: onSelectedItemChanged,
    scrollController: controller,
    itemExtent: 40,
    children: pickerList.map((value){
      return Container(
        alignment: Alignment.center,
        height: 40,
        child: Text(value),
      );
    }).toList(),
  );

  final selectBtn = Container(
    alignment: Alignment.topRight,
    padding: EdgeInsets.only(right: 10),
    child: Material(
      color: Colors.white,
      child: InkWell(
        child: Container(
          padding: EdgeInsets.all(5),
          child: Text(
            "선택하기",
            style: TextStyle(
              color: quickBlue24,
              fontSize: 17,
            ),
          ),
        ),
        onTap: onTap,
      ),
    ),
  );

  final bottomSheet = Container(
    height: 300,
    color: Colors.white,
    child: Column(
      children: <Widget>[
        SizedBox(height: 10,),
        selectBtn,
        SizedBox(height: 10,),
        Text(
          "분야별",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        SizedBox(height: 10,),
        Expanded(
          child: picker,
        ),
      ],
    ),
  );

  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => bottomSheet
  );
}

String httpGetQuery(String query, String key, String value){
  if(value == null){
    return query;
  }

  String firstWord = query == null ? "?": "$query&";
  return "$firstWord$key=$value";
}

Dialog getCallDialog(BuildContext context, String name){
  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), //this right here
    child: Container(
      height: 280.0,
      width: 300.0,
      padding: EdgeInsets.only(left: 20, right: 20, top: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              "$name",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(height: 20,),
          Center(
            child: Text(
              '''"쾌변을 통해 연락 드렸습니다."라고 말씀해주시고 궁금한 점을 문의해 주세요.''',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(height: 20,),
          Text(
            "* 일반 전화요금과 동일합니다",
            style: TextStyle(
              color: quickGray93,
              fontSize: 12,
            ),
          ),
          Text(
            "* 상담예약을 이요해주시면 빠르고 정학하게 안내받으실 수 있습니다.",
            style: TextStyle(
              color: quickGray93,
              fontSize: 12,
            ),
          ),
          Spacer(),
          SizedBox(
            height: 60,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    child: Text(
                        '취소',
                        style: TextStyle(
                            color: quickBlue1b,
                            fontSize: 18.0)
                    ),
                    onPressed: (){Navigator.of(context).pop(false);},
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    child: Text(
                        '전화걸기',
                        style: TextStyle(
                            color: quickBlue1b,
                            fontSize: 18.0)
                    ),
                    onPressed: (){Navigator.of(context).pop(true);},
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}


Widget redDot({Widget child, double alignmentY = 1}){
  return Row(
    children: <Widget>[
      Container(
        alignment: Alignment(0,alignmentY),
        height: double.infinity,
        child: Text(
          "˙",
          style: TextStyle(
            fontSize: 35,
            color: quickRedFF,
          ),
        ),
      ),
      Expanded(
        child: child,
      )
    ],
  );
}
