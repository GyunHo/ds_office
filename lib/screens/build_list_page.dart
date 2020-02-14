import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kf_drawer/kf_drawer.dart';
import 'package:flutter/material.dart';

class BuildListPage extends KFDrawerContent {
  @override
  _BuildListPageState createState() => _BuildListPageState();
}

class _BuildListPageState extends State<BuildListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "addbuild",
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.of(context).pushNamed("buildreport");
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "시설내역서",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: widget.onMenuPressed,
          icon: Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('buildlist').snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Container(
            child: Center(
              child: Text('빌드 페이지'),
            ),
          );
        },
      ),
    );
  }
}
