import 'package:barcode_mj/ui/category_list.dart';
import 'package:barcode_mj/util/resource.dart';
import 'package:flutter/cupertino.dart';
import 'category_page.dart';


class CategoryPageView extends StatefulWidget{
  @override
  CategoryPageViewState createState() => CategoryPageViewState();

}

class CategoryPageViewState extends State<CategoryPageView>{
  PageController _pageController;
  int pageIndex = 0;

  List<Widget> widgetList = [CategoryList()];


  @override
  void initState() {
    super.initState();
    final pageList = categoryList.map((category)=>CategoryPage(category:category)).toList();
    widgetList.addAll(pageList);

    int firstViewOffset = 4;

    _pageController = PageController(initialPage: firstViewOffset + 999);
  }

  @override
  Widget build(BuildContext context) {
    return infinityPageView();
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