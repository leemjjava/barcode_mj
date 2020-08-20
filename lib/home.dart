import 'package:barcode_mj/product_page_view.dart';
import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'custom_ui/button.dart';

class Home extends StatefulWidget{
  @override
  HomeState createState()=> HomeState();
}

class HomeState extends State<Home>{

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
}