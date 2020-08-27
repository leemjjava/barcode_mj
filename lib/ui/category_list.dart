import 'package:barcode_mj/custom_ui/layout.dart';
import 'package:barcode_mj/provider/product_provider.dart';
import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../bloc/product_bloc.dart';

class CategoryList extends StatefulWidget{
  @override
  CategoryListState createState()=> CategoryListState();
}

class CategoryListState extends State<CategoryList>{
  RefreshController refreshController = RefreshController(initialRefresh: false);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String topTitle;
  final bloc = ProductBloc();
  List<DocumentSnapshot> _documents;
  Timestamp startTimeStamp;

  @override
  void initState() {
    super.initState();
    topTitle = "카테고리 미 입력";
    startTimeStamp = Timestamp.now();
    getList();
  }

  void getList() async{
    try{
      List<DocumentSnapshot> documents = await bloc.getCategory(inputCategoryList[0], startTimeStamp);

      if(_documents == null) _documents = [];

      if( _documents.length == 0) refreshController.refreshCompleted();
      else refreshController.loadComplete();

      if(documents.isEmpty == false){
        final lastDocuments = documents[documents.length -1];
        startTimeStamp = lastDocuments.data()[fnDatetime];
        _documents.addAll(documents);
      }

      setState(() {});

    }catch(error, stacktrace){
      print("$error");
      print(stacktrace.toString());

      showAlert(context,'$error : ${stacktrace.toString()}');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Column(
          children: [
            TopRefreshBar(
              title: topTitle,
              background: quickBlue69,
              textColor: Colors.white,
              onRefresh: (){
                refreshController.requestRefresh(duration: const Duration(milliseconds: 100));
              },
            ),
            Expanded(
              child: refresher(),
            ),
          ],
        ),
      ),
    );
  }

  Widget refresher(){
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: ClassicHeader(
        idleText: "당겨서 리프레시",
        completeText: "완료",
        refreshingText: "리프레시 중...",
        releaseText: "새로고침",
      ),
      footer: CustomFooter(
        builder: (BuildContext context,LoadStatus mode){
          Widget body;
          if(mode == LoadStatus.idle) body =  Text("마지막", style: TextStyle(color: quickGrayA8),);
          else if(mode == LoadStatus.loading) body =  CupertinoActivityIndicator();

          return Container(
            height: 55.0,
            child: Center(child:body),
          );
        },
      ),
      controller: refreshController,
      onRefresh: refreshList,
      onLoading: ()=>getList(),
      child: listView(),
    );
  }

  refreshList(){
    startTimeStamp = Timestamp.now();
    _documents = null;
    getList();
    setState(() {});
  }



  Widget listView(){
    if(_documents == null){
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(100),
        child: LinearProgressIndicator(
          minHeight: 5,
          backgroundColor: Colors.transparent,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      );
    }
    if(_documents.length == 0){
      return Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Text("데이터가 없습니다."),
      );
    }

    return ListView.builder(
      itemCount: _documents.length,
      itemBuilder: (BuildContext context, int index) {
        final document = _documents[index];

        return CategoryCard(
            map: document.data(),
            onTap: (){},
            updateCategory:(category)=>updateCategory(category, index),
        );
      }
    );
  }

  void updateCategory(String category, int index){
    final docId = _documents[index].id;

    FirebaseFirestore.instance.collection(colName).doc(docId).update({
      fnCategory: category
    }).then((value){
      _documents.removeAt(index);
      setState(() {});
    });
  }
}