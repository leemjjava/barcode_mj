import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class UnderLineTfCS extends StatelessWidget{
  UnderLineTfCS({
    Key key,
    this.controller,
    this.obscure = false,
    this.underLineColor = quickBlue01,
    this.cursorColor = quickBlue01,
    this.textColor = Colors.black,
    this.hint,
    this.fontSize = 13,
    this.height = 40,
    this.width = 1,
    this.isOnlyDigits = false,
    this.isWonDigits = false,
  }) : super(key: key);

  TextEditingController controller;
  bool obscure;
  bool isOnlyDigits;
  bool isWonDigits;

  Color underLineColor;
  Color cursorColor;
  Color textColor;

  String hint;

  double fontSize;
  double height;
  double width;

  @override
  Widget build(BuildContext context) {

    if(isWonDigits){
      return onlyWonDigits();
    }
    if(isOnlyDigits){
      return onlyDigits();
    }

    return Container(
      height: height,
      child : TextField(
        controller: controller,
        style: TextStyle(fontSize: fontSize, color: textColor),
        obscureText: obscure,
        decoration: textFieldDeco(),
        cursorColor: cursorColor,
      ),
    );
  }

  Widget onlyDigits(){
    return Container(
      height: height,
      child : TextField(
        controller: controller,
        style: TextStyle(fontSize: fontSize, color: textColor),
        obscureText: obscure,
        decoration: textFieldDeco(),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly,
        ],
        cursorColor: cursorColor,
      ),
    );
  }

  Widget onlyWonDigits(){
    return Container(
      height: height,
      child : TextField(
        controller: controller,
        style: TextStyle(fontSize: fontSize, color: textColor),
        obscureText: obscure,
        decoration: textFieldDeco(),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly,
          NumericTextFormatter(),
        ],
        cursorColor: cursorColor,
      ),
    );
  }


  InputDecoration textFieldDeco(){
    return InputDecoration(
      contentPadding: EdgeInsets.only(bottom: 0),
      border: UnderlineInputBorder(
        borderSide: BorderSide(
          color: underLineColor,
          width: width,
        ),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: underLineColor,
          width: width,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: underLineColor,
          width: width,
        ),
      ),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[300]),

    );
  }
}

// ignore: must_be_immutable
class OutLineTfCS extends StatelessWidget{
  OutLineTfCS({
    Key key,
    this.controller,
    this.obscure = false,
    this.outLineColor = quickBlue01,
    this.cursorColor = quickBlue01,
    this.textColor = Colors.black,
    this.hint,
    this.fontSize = 13,
    this.height = 40,
    this.inputType = TextInputType.text,
    this.maxLine = 1,
    this.maxLength = 60,
    this.counterText,
    this.onChanged,
    this.isPhone
  }) : super(key: key);

  TextEditingController controller;
  bool obscure, isPhone;
  TextInputType inputType;
  int maxLine;
  int maxLength;

  Color outLineColor;
  Color cursorColor;
  Color textColor;

  String hint;
  String counterText;

  double fontSize;
  double height;
  ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {

    List<TextInputFormatter> formatters;
    if(isPhone == true){
      formatters = <TextInputFormatter>[
        LengthLimitingTextInputFormatter(11),
        WhitelistingTextInputFormatter.digitsOnly,
        BlacklistingTextInputFormatter.singleLineFormatter,
      ];
    }


    return Container(
      height: height,
      child : TextField(
        textAlignVertical: TextAlignVertical.center,
        textAlign: TextAlign.left,
        controller: controller,
        style: TextStyle(fontSize: fontSize, color: textColor),
        keyboardType: inputType,
        maxLines: this.maxLine,
        maxLength: this.maxLength,
        obscureText: obscure,
        onChanged: onChanged,
        decoration: InputDecoration(
          counterText: counterText,
          contentPadding: EdgeInsets.only(left: 10, top: 10),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: outLineColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: outLineColor,
            ),
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[300]),
        ),
        cursorColor: cursorColor,
        inputFormatters: formatters,
      ),
    );
  }
}

class NumericTextFormatter extends TextInputFormatter {
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length == 0) {
      return newValue.copyWith(text: '');
    } else if (newValue.text.compareTo(oldValue.text) != 0) {
      int selectionIndexFromTheRight = newValue.text.length - newValue.selection.end;
      final f = NumberFormat("#,###");
      int num = int.parse(newValue.text.replaceAll(f.symbols.GROUP_SEP, ''));
      final newString = f.format(num);
      return TextEditingValue(
        text: newString,
        selection: TextSelection.collapsed(offset: newString.length - selectionIndexFromTheRight),
      );
    } else {
      return newValue;
    }
  }
}

class CapitalTfCS extends StatelessWidget{
  CapitalTfCS({
    Key key,
    @required this.capitalTec,
    @required this.showCapital,
  }): super(key:key);


  final TextEditingController capitalTec;
  final String showCapital;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        capitalTf(),
        Container(
          margin: EdgeInsets.only(left: 15, right: 20),
          child: Text(
            showCapital,
            style: TextStyle(color: quickGrayBF),
          ),
        ),
      ],
    );
  }

  Widget capitalTf(){
    return Container(
      margin: EdgeInsets.only(bottom: 5, left: 10, right: 20),
      height: 50,
      child: redDot(
        child: UnderLineTfCS(
          controller: capitalTec,
          textColor: quickBlack00,
          underLineColor: quickBlack0d,
          cursorColor: quickBlack0d,
          hint: '거래금액(원)',
          height: 40,
          width: 1.0,
          isWonDigits: true,
        ),
      ),
    );
  }
}