import 'package:barcode_mj/util/resource.dart';
import 'package:barcode_mj/util/util.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'custom_ui/layout.dart';

class FirestoreFirstDemo extends StatefulWidget {
  @override
  FirestoreFirstDemoState createState()=>FirestoreFirstDemoState();
}

class FirestoreFirstDemoState extends State<FirestoreFirstDemo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // 컬렉션명
  final String colName = "FirstDemo";

  // 필드명
  final String fnName = "name";
  final String fnDescription = "description";
  final String fnDatetime = "datetime";

  FirebaseFirestore firestore;
  Stream<QuerySnapshot> _stream;
  List<QueryDocumentSnapshot> _documents = [];
  TextEditingController _newNameCon = TextEditingController();
  TextEditingController _newDescCon = TextEditingController();
  TextEditingController _undNameCon = TextEditingController();
  TextEditingController _undDescCon = TextEditingController();

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    _stream = firestore
        .collection(colName)
        .orderBy(fnDatetime, descending: true)
        .snapshots();

    _listenStream();
  }

  void _listenStream(){
    _stream.listen((snapshot) {
      _documents = snapshot.docs;
      setState(() {});

    },onError:(error, stacktrace){
      print("onError: $error");
      print(stacktrace.toString());
      showAlert(context,stacktrace.toString());
    });
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Column(
          children: [
            TopBar(title: "상품 등록 현황",),
            Expanded(
              child: lawyerListView(),
            )
          ],
        ),
        // Create Document
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add), onPressed: showCreateDocDialog),
      ),
    );
  }

  Widget lawyerListView(){
    return ListView.builder(
      itemCount: _documents.length,
      itemBuilder: (BuildContext context, int index) {
        return listItemView(_documents[index]);
      },
    );
  }

  Widget listItemView(DocumentSnapshot document){
    final itemMap = document.data();
    Timestamp ts = itemMap[fnDatetime];
    String dt = timestampToStrDateTime(ts);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: ()=> showDocument(document.id),
        onLongPress: ()=> showUpdateOrDeleteDocDialog(document),
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                height: 50,
                child: Text('${itemMap[fnName]}',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              descriptionWidget('값', 15),
              descriptionWidget('${itemMap[fnDescription]}', 25),
              descriptionWidget('바코드', 15),
              descriptionWidget('123456789', 25),
              Text(
                dt,
                style:
                TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
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

  void createDoc(String name, String description) {
    firestore.collection(colName).add({
      fnName: name,
      fnDescription: description,
      fnDatetime: Timestamp.now(),
    });
  }

  void showDocument(String documentID) {
    firestore.collection(colName).doc(documentID).get().then((doc) {
      showReadDocSnackBar(doc);
    });
  }

  void updateDoc(String docID, String name, String description) {
    firestore.collection(colName).doc(docID).update({
      fnName: name,
      fnDescription: description,
    });
  }

  void deleteDoc(String docID) {
    firestore.collection(colName).doc(docID).delete();
  }

  void showCreateDocDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Create New Document"),
          content: Container(
            height: 200,
            child: Column(
              children: <Widget>[
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(labelText: "Name"),
                  controller: _newNameCon,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Description"),
                  controller: _newDescCon,
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                _newNameCon.clear();
                _newDescCon.clear();
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Create"),
              onPressed: () {
                if (_newDescCon.text.isNotEmpty && _newNameCon.text.isNotEmpty) {
                  createDoc(_newNameCon.text, _newDescCon.text);
                }
                _newNameCon.clear();
                _newDescCon.clear();
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void showReadDocSnackBar(DocumentSnapshot doc) {
    final itemMap = doc.data();
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.deepOrangeAccent,
          duration: Duration(seconds: 5),
          content: Text(
              "$fnName: ${itemMap[fnName]}\n$fnDescription: ${itemMap[fnDescription]}"
                  "\n$fnDatetime: ${timestampToStrDateTime(itemMap[fnDatetime])}"),
          action: SnackBarAction(
            label: "Done",
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
  }

  void showUpdateOrDeleteDocDialog(DocumentSnapshot doc) {
    final itemMap = doc.data();
    _undNameCon.text = itemMap[fnName];
    _undDescCon.text = itemMap[fnDescription];

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update/Delete Document"),
          content: Container(
            height: 200,
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: "Name"),
                  controller: _undNameCon,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Description"),
                  controller: _undDescCon,
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                _undNameCon.clear();
                _undDescCon.clear();
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Update"),
              onPressed: () {
                if (_undNameCon.text.isNotEmpty && _undDescCon.text.isNotEmpty) {
                  updateDoc(doc.id, _undNameCon.text, _undDescCon.text);
                }
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Delete"),
              onPressed: () {
                deleteDoc(doc.id);
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  String timestampToStrDateTime(Timestamp ts) {
    return DateTime
        .fromMicrosecondsSinceEpoch(ts.microsecondsSinceEpoch)
        .toString();
  }
}