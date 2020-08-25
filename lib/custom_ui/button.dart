import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:flutter/material.dart';


// ignore: must_be_immutable
class ExpandBtnCS extends StatelessWidget{

  ExpandBtnCS({
    Key key,
    this.title = "Button",
    this.buttonColor = Colors.grey,
    this.textColor = Colors.white,
    this.onPressed,
    this.height = 40,
    this.width = double.infinity,
    this.fontSize,
    this.radius,
    this.fontWeight
  }) :super(key : key);

  String title;
  Color buttonColor;
  Color textColor;
  VoidCallback onPressed;
  double height;
  double width;
  double fontSize;
  double radius;
  FontWeight fontWeight;


  @override
  Widget build(BuildContext context) {
    radius = radius == null ? (height / 2) : radius;
    fontSize = fontSize == null ? (height / 3) : fontSize;
    fontWeight = fontWeight == null ? FontWeight.w300 : fontWeight;

    return Container(
        width: width,
        height: height,
        child: FlatButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          color: buttonColor,
          textColor: textColor,
          child: Text(title,
            style:
            TextStyle(
              fontWeight: fontWeight,
              fontSize: fontSize,
            ),
          ),
          onPressed: onPressed,
        )
    );
  }
}

// ignore: must_be_immutable
class BorderBtnCS extends StatelessWidget{

  BorderBtnCS({
    Key key,
    this.title = "Button",
    this.buttonColor = Colors.white,
    this.textColor = quickBlue01,
    this.borderColor = quickBlue01,
    this.width = double.infinity,
    this.height = 40,
    this.fontSize = 14,
    this.radius,
    this.onPressed,
    this.fontWeight,
    this.borderWeight = 1
  }) : super(key : key);

  String title;
  Color buttonColor;
  Color textColor;
  Color borderColor;

  double width;
  double height;
  double fontSize;
  double radius;
  double borderWeight;

  VoidCallback onPressed;
  FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    radius = radius == null ? (height / 2) : radius;

    return Container(
        width: width,
        height: height,
        child: FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
              side: BorderSide(
                width: borderWeight,
                color: borderColor,
              )
          ),
          onPressed: onPressed,
          color: buttonColor,
          child:Text(
              title,
              style: TextStyle(
                fontWeight: fontWeight,
                fontSize: fontSize,
                color: textColor,
              )
          ),
      )
    );
  }
}

// ignore: must_be_immutable
class DefaultBtnCS extends StatelessWidget{

  DefaultBtnCS({
    Key key,
    this.title = "Button",
    this.buttonColor = Colors.grey,
    this.textColor = Colors.white,
    this.onPressed,
    this.height = 40,
    this.width,
    this.fontSize,
    this.radius,
    this.fontWeight
  }) :super(key : key);

  String title;
  Color buttonColor;
  Color textColor;
  VoidCallback onPressed;
  double height;
  double width;
  double fontSize;
  double radius;
  FontWeight fontWeight;


  @override
  Widget build(BuildContext context) {
    radius = radius == null ? (height / 2) : radius;
    fontSize = fontSize == null ? (height / 3) : fontSize;
    fontWeight = fontWeight == null ? FontWeight.w300 : fontWeight;

    return Container(
        width: width,
        height: height,
        child: FlatButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          color: buttonColor,
          textColor: textColor,
          child: Text(title,
            style:
            TextStyle(
              fontWeight: fontWeight,
              fontSize: fontSize,
            ),
          ),
          onPressed: onPressed,
        )
    );
  }
}

// ignore: must_be_immutable
class InkWellCS extends StatelessWidget{
  InkWellCS({
    Key key,
    this.child,
    this.onTap,
    this.onLongPress,
    this.backgroundColor = Colors.white,
    this.splashColor,
  }):super(key:key);

  final Widget child;
  GestureTapCallback onTap;
  GestureTapCallback onLongPress;
  Color splashColor;
  Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: InkWell(
        splashColor: splashColor,
        child: child,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}

// ignore: must_be_immutable
class DropDownBtnCS extends StatelessWidget{

  DropDownBtnCS({
    Key key,
    this.value,
    @required this.hint,
    @required this.itemList,
    @required this.onChanged,
  }) :super(key:key);

  String value;
  final String hint;
  final List<String> itemList;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: DropdownButton<String>(
        isExpanded: true,
        hint: Text(hint),
        value: value,
        icon: Icon(Icons.keyboard_arrow_down),
        iconSize: 24,
        elevation: 16,
        itemHeight: 60,
        style: TextStyle(color: quickBlack0d),
        underline: Container(
          height: 1,
          color: quickBlack0d,
        ),
        onChanged: onChanged,
        items: itemList
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Container(
              width: double.infinity,
              child: Text(value),
            ),
          );
        }).toList(),
      ),
    );
  }
}