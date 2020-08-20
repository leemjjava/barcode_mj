import 'package:barcode_mj/product_list.dart';
import 'package:barcode_mj/util/resource.dart';
import 'package:flutter/cupertino.dart';

// ignore: must_be_immutable
class ProductPageView extends StatefulWidget{
  ProductPageView({
    Key key,
    this.type
  }): super(key : key);
  String type;

  @override
  ProductPageViewState createState() => ProductPageViewState();

}

class ProductPageViewState extends State<ProductPageView>{
  PageController _pageController;
  int pageIndex = 0;

  final widgetList = [
    ProductList(type: productListTypeNotInput,),
    ProductList(type: productListTypeAll,),
    ProductList(type: productListTypeInput,),
  ];


  @override
  void initState() {
    super.initState();
    int initialPage = 0;
    if(widget.type == productListTypeNotInput) initialPage = 0;
    else if(widget.type == productListTypeAll) initialPage = 1;
    else initialPage = 2;

    _pageController = PageController(initialPage: initialPage + 999);
  }

  @override
  Widget build(BuildContext context) {
//    return mainPageView();
    return infinityPageView();
  }

  Widget mainPageView(){
    return PageView(
      controller: _pageController,
      children: <Widget>[
        ProductList(type: productListTypeNotInput,),
        ProductList(type: productListTypeAll,),
        ProductList(type: productListTypeInput,),
      ],
      onPageChanged: (index){
        setState(() {
          FocusScope.of(context).requestFocus(new FocusNode());
          pageIndex = index;
        });
      },
    );
  }

  Widget infinityPageView(){
    return PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) {
          return widgetList[index % widgetList.length];
        }
    );
  }
}