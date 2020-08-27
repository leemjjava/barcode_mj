import 'package:barcode_mj/custom_ui/layout.dart';
import 'package:barcode_mj/ui/category_page_view.dart';
import 'package:barcode_mj/ui/product_page_view.dart';
import 'package:barcode_mj/ui/search_list.dart';
import 'package:barcode_mj/ui/send_csv_view.dart';
import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget{
  @override
  HomeState createState()=> HomeState();
}

class HomeState extends State<Home>{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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
                SizedBox(height: 30,),
                ShadowBox(
                  icon: Icon(Icons.assignment_late, size: 40, color: Colors.red,),
                  title: "미입력 상품",
                  content: "포스기에 미등록된 상품 리스트",
                  onTap: ()=>serviceItemOnTap(productListTypeNotInput),
                ),
                SizedBox(height: 15,),
                ShadowBox(
                  icon: Icon(Icons.assignment, size: 40, color: Colors.blue),
                  title: "입력 상품",
                  content: "포스기에 등록된 상품 리스트",
                  onTap: ()=>serviceItemOnTap(productListTypeInput),
                ),
                SizedBox(height: 15,),
                ShadowBox(
                  icon: Icon(Icons.category, size: 40, color: quickYellowFB),
                  title: "카테고리 입력",
                  content: "카테고리를 입력하고 카테고리 별로 목록을 확인합니다.",
                  onTap: ()=>categoryOnTap(),
                ),
                SizedBox(height: 15,),
                ShadowBox(
                  icon: Icon(Icons.search, size: 40, color: Colors.orange),
                  title: "포스기 상품 검색",
                  content: "포스기에 등록되어 있는 상품 검색합니다.",
                  onTap: ()=>searchOnTap(),
                ),
                SizedBox(height: 15,),
                ShadowBox(
                  icon: Icon(Icons.email, size: 40, color: Colors.green),
                  title: "엑셀 파일 전송",
                  content: "모든 상품 데이터 파일을 메일로 전송합니다.",
                  onTap: ()=>sendCsvOnTap(),
                ),
                SizedBox(height: 30,),
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

  void sendCsvOnTap(){
    Route route = createSlideUpRoute(widget : SendCsvView());
    Navigator.push(context, route);
  }
}