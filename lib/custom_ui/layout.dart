import 'dart:math';

import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'button.dart';

// ignore: must_be_immutable
class TopBar extends StatelessWidget{
  TopBar({
    Key key,
    this.title,
    this.onTap,
    this.closeIcon,
    this.background = Colors.white,
    this.textColor = Colors.black,
  }):super(key:key);

  String title;
  Function onTap;
  Icon closeIcon;
  Color background, textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      color: background,
      child: Stack(
        children: <Widget>[
          TopTitle(
            title:title,
            background: background,
            textColor: textColor,
          ),
          SizedBox(
            height: double.infinity,
            width: 60,
            child: Material(
              color: background,
              child: InkWell(
                splashColor: quickGray75,
                onTap: onTap != null ? onTap: ()=>Navigator.pop(context),
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  alignment: Alignment.centerLeft,
                  child: closeIcon == null ? Icon(Icons.close, color: textColor,) : closeIcon,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class TopTitle extends StatelessWidget{
  TopTitle({
    Key key,
    this.title,
    this.background = Colors.white,
    this.textColor = Colors.black,
  }):super(key:key);

  String title;
  Color background, textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      child: SizedBox(
        height: 60,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class TopRefreshBar extends StatelessWidget{
  TopRefreshBar({
    Key key,
    this.title,
    this.onTap,
    this.onRefresh,
    this.closeIcon,
    this.background = Colors.white,
    this.textColor = Colors.black,
  }):super(key:key);

  String title;
  Function onTap;
  GestureTapCallback onRefresh;
  Icon closeIcon;
  Color background, textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      color: background,
      child: Stack(
        children: <Widget>[
          TopTitle(
            title:title,
            background: background,
            textColor: textColor,
          ),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            height: double.infinity,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              InkWellCS(
                  backgroundColor: background,
                  splashColor: quickGray75,
                  onTap: onTap != null ? onTap: ()=>Navigator.pop(context),
                  child: closeIcon == null ? Icon(Icons.close, color: textColor,) : closeIcon,
                ),
                InkWellCS(
                  backgroundColor: background,
                  child: Icon(
                    Icons.refresh,
                    color: textColor,
                    size: 30,
                  ),onTap:onRefresh,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TopSearchBar extends StatelessWidget{
  TopSearchBar({
    Key key,
    @required this.searchTec,
    this.padding
  }):super(key:key);

  EdgeInsets padding;
  final TextEditingController searchTec;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: padding,
      height: 58,
      width: double.infinity,
      alignment: Alignment.center,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: searchTec,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "쾌변 통합 검색",
                hintStyle: TextStyle(color:Color(0xFFA0A0A0)),
              ),
              onSubmitted: (value){
                search(context);
              },
            ),
          ),
          InkWellCS(
            child: Icon(
              Icons.search,
              color: Color(0xff014f90),
              size: 30,
            ),onTap:()=> search(context),
          ),
        ],
      ),
    );
  }

  search(BuildContext context){
    String keyword = searchTec.text;
    if(keyword == null || keyword.isEmpty){
      showAlert(context, "검색어를 입력해 주세요.");
      return;
    }
    searchTec.clear();
    FocusScope.of(context).requestFocus(new FocusNode());

  }
}

class SliverHeaderDelegateCS extends SliverPersistentHeaderDelegate {
  SliverHeaderDelegateCS({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.maxChild,
    @required this.minChild,
  });
  final double minHeight, maxHeight;
  final Widget maxChild, minChild;

  double visibleMainHeight, animationVal, width;

  @override
  bool shouldRebuild(SliverHeaderDelegateCS oldDelegate) => true;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => max(maxHeight, minHeight);

  double scrollAnimationValue(double shrinkOffset) {
    double maxScrollAllowed = maxExtent - minExtent;

    return ((maxScrollAllowed - shrinkOffset) / maxScrollAllowed)
        .clamp(0, 1)
        .toDouble();
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    width = MediaQuery.of(context).size.width;
    visibleMainHeight = max(maxExtent - shrinkOffset, minExtent);
    animationVal = scrollAnimationValue(shrinkOffset);

    return Container(
        height: visibleMainHeight,
        width: MediaQuery.of(context).size.width,
        color: Color(0xFFFFFFFF),
        child: Stack(
          children: <Widget>[
            getMinTop(),
            animationVal != 0 ? getMaxTop() : Container(),
          ],
        )
    );
  }

  Widget getMaxTop(){
    return Positioned(
      bottom: 0.0,
      child: Opacity(
        opacity: animationVal,
        child: SizedBox(
          height: maxHeight,
          width: width,
          child: maxChild,
        ),
      ),
    );
  }

  Widget getMinTop(){
    return Opacity(
      opacity: 1 - animationVal,
      child: Container(
          height: visibleMainHeight,
          width: width,
          child: minChild
      ),
    );
  }
}

class GrayTextCS extends StatelessWidget{
  GrayTextCS({
    Key key,
    this.title,
    this.height
  }) : super(key:key);

  final String title;
  final double height;

  @override
  Widget build(BuildContext context) {
    double radius = height / 2;

    return Container(
      margin: EdgeInsets.only(right: 5),
      height: height,
      padding: EdgeInsets.only(left: radius, right: radius),
      decoration: BoxDecoration(
        color: quickGrayEC,
        borderRadius: BorderRadius.all(
          Radius.circular(radius),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          color: quickBlack4E,
          fontSize: 13,
        ),
      ),
    );
  }

}

class DetailTitle extends StatelessWidget{
  DetailTitle({
    Key key,
    @required this.title,
  }): super(key:key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800
      ),
    );
  }

}

// ignore: must_be_immutable
class PriceCard extends StatelessWidget{
  PriceCard({
    Key key,
    @required this.map,
    @required this.onTap,
    @required this.onCheckTap,
    @required this.onLongPress,
  }) : super(key:key);

  Map<String, dynamic> map;
  GestureTapCallback onTap;
  GestureTapCallback onCheckTap;
  GestureLongPressCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    Timestamp ts = map[fnDatetime];
    String dt = timestampToStrDateTime(ts);
    String isInput = map[fnIsInput];
    Color background;
    Icon checkIcon;

    if(isInput == 'Y'){
      background = inputGreenEB;
      checkIcon = Icon(Icons.refresh, color: Colors.red,);
    }else{
      background = Colors.white;
      checkIcon = Icon(Icons.check, color: Colors.green,);
    }

    return Card(
      margin: EdgeInsets.all(10),
      elevation: 2,
      color: background,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              titleText(map[fnName]),
              Row(
                children: [
                  Expanded(
                    child: contentColumn(map[fnPrice], map[fnBarcode]),
                  ),
                  InkWellCS(
                    backgroundColor: Colors.transparent,
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: checkIcon,
                    ),
                    onTap: onCheckTap,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dt,
                    style:
                    TextStyle(color: Colors.grey[600]),
                  ),
                  countColumn(map[fnCount]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget contentColumn(String price, String barcode){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        descriptionWidget('가격', 15),
        descriptionWidget(price??'', 25),
        descriptionWidget('바코드', 15),
        descriptionWidget(barcode??'', 25),
      ],
    );
  }

  Widget countColumn(String count){

    return Column(
      children: [
        descriptionWidget('재고', 15),
        descriptionWidget(count??'입력없음', 15),
      ],
    );
  }

  Widget titleText(String name){
    return Container(
      alignment: Alignment.centerLeft,
      height: 50,
      child: Text('$name',
        style: TextStyle(
          color: Colors.blueGrey,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget descriptionWidget(String content, double size){
    return Text(
      content,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
        fontSize: size,
        color: quickBlack03,
      ),
    );
  }

}

typedef UpdateCategory = void Function(String title);

// ignore: must_be_immutable
class CategoryCard extends StatelessWidget{
  CategoryCard({
    Key key,
    @required this.map,
    @required this.onTap,
    @required this.updateCategory,
  }) : super(key:key);

  UpdateCategory updateCategory;
  Map<String, dynamic> map;
  GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    Timestamp ts = map[fnDatetime];
    String dt = timestampToStrDateTime(ts);

    return Card(
      margin: EdgeInsets.all(10),
      elevation: 2,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              titleText(map[fnName]),
              descriptionWidget(map[fnBarcode], 17),
              SizedBox(height: 10,),
              buttonLayout(1),
              SizedBox(height: 10,),
              buttonLayout(2),
              SizedBox(height: 10,),
              buttonLayout(3),
              SizedBox(height: 10,),
              buttonLayout(4),
              SizedBox(height: 10,),
              Text(dt,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buttonLayout(int index){
    int listCount = (index * 3) - 3;
    int maxCount = categoryList.length;

    String title01 = listCount < maxCount ? categoryList[listCount]: null;
    ++listCount;
    String title02 = listCount < maxCount ? categoryList[listCount]: null;
    ++listCount;
    String title03 = listCount < maxCount ? categoryList[listCount]: null;

    return Row(
      children: <Widget>[
        title01 != null ? categoryBtn(title01): Expanded(child: Container(),),
        title02 != null ? categoryBtn(title02): Expanded(child: Container(),),
        title03 != null ? categoryBtn(title03): Expanded(child: Container(),),
      ],
    );
  }

  Widget categoryBtn(String title){
    return Expanded(
      child: BorderBtnCS(
        title: title ?? '',
        height: 30,
        fontWeight: FontWeight.w800,
        onPressed: ()=>updateCategory(title),
      ),
    );
  }

  Widget titleText(String name){
    return Container(
      alignment: Alignment.centerLeft,
      height: 50,
      child: Text('$name',
        overflow: TextOverflow.clip,
        style: TextStyle(
          color: Colors.blueGrey,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget descriptionWidget(String content, double size){
    return Text(
      content,
      overflow: TextOverflow.clip,
      style: TextStyle(
        fontSize: size,
        color: quickBlack03,
      ),
    );
  }

}