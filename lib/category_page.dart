import 'package:barcode_mj/custom_ui/layout.dart';
import 'package:barcode_mj/product_view.dart';
import 'package:barcode_mj/provider/product_provider.dart';
import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'bloc/product_bloc.dart';
import 'custom_ui/alert_dialog.dart';

class CategoryPage extends StatefulWidget{
  CategoryPage({
    Key key,
    this.category,
  }) :super(key:key);

  final String category;

  @override
  CategoryPageState createState()=> CategoryPageState();
}

class CategoryPageState extends State<CategoryPage>{
  RefreshController refreshController = RefreshController(initialRefresh: false);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseFirestore firestore;

  final bloc = ProductBloc();
  List<DocumentSnapshot> _documents;
  Timestamp startTimeStamp;

  @override
  void initState() {
    super.initState();
    startTimeStamp = Timestamp.now();
    getList();
  }

  void getList() async{
    try{
      List<DocumentSnapshot> documents = await bloc.getCategory(widget.category, startTimeStamp);

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
              title: widget.category,
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

          return PriceCard(
            map: document.data(),
            onTap: ()=> showUpdateOrDeleteDocDialog(document, index),
            onCheckTap: ()=> updateIsInputView(document, index),
            onLongPress: ()=> showProductView(document.id),
          );
        }
    );
  }

  void showProductView(String docID){
    Route route = createSlideUpRoute(widget : ProductView(docId: docID,));
    Navigator.push(context, route);
  }

  void showUpdateOrDeleteDocDialog(DocumentSnapshot doc, int index) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context){
        return ProductUpdateDialog(
          showReadDocSnackBar: showReadDocSnackBar,
          doc: doc,
          changeLocalItem:(isDelete)=>changeLocalItem(index),
        );
      },
    );
  }

  void changeLocalItem(int index) async {
    final document = _documents[index];
    _documents.removeAt(index);

    final newDocument = await getDocument(document.id);
    setState((){
      if(index == _documents.length -1)_documents.add(newDocument);
      _documents.insert(index, newDocument);
      showReadDocSnackBar('${document.data()[fnName]} 수정');
    });
  }

  void showDeleteSnackBar(String name){
    setState(() {
      showReadDocSnackBar('$name 입력 상태 변경');
    });
  }

  Future<DocumentSnapshot> getDocument(String docID) {
    return firestore
        .collection(colName)
        .doc(docID)
        .get();
  }

  void updateIsInputView(DocumentSnapshot document, int index) async{
    final isInput = document.data()[fnIsInput];
    final inputType = isInput == 'Y' ? 'N' : 'Y';

    final isSuccess = await updateIsInput(document.id, inputType);
    if(isSuccess) changeLocalItem(index);
  }

  Future<bool> updateIsInput(String docId, String inputType) async{
    try{
      await firestore
          .collection(colName)
          .doc(docId)
          .update({fnIsInput: inputType});

      return true;
    }catch(error, stacktrace){
      print("$error");
      print(stacktrace.toString());

      showAlert(context,'$error : ${stacktrace.toString()}');
    }

    return false;
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