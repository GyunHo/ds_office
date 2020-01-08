import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ds_office/db/quality_check_bloc.dart';
import 'package:ds_office/screens/quality_result_page_.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kf_drawer/kf_drawer.dart';
import 'package:provider/provider.dart';

class QualityListPage extends KFDrawerContent {
  @override
  _QualityCheckPageState createState() => _QualityCheckPageState();
}

class _QualityCheckPageState extends State<QualityListPage> {


  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<QualityCheckBloc>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () async {
          await Navigator.of(context).pushNamed('qualitycheck').then((val) {
            if (val) {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('저장 됐습니다.'),
              ));
            }
          }).catchError((e) {
            print("저장 실패 했는데 원래 페이지로 왜돌아왔지?");
          });
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.menu,
              color: Colors.white,
            ),
          ),
        ],
        centerTitle: true,
        title: Text('품질점검'),
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
        stream: Firestore.instance
            .collection('checklist')
            .orderBy('점검일', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                TextField(
                  enabled: false,
                  decoration: InputDecoration(
                      hintText: "국소명 검색",
                      labelText: "구현예정",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.black))),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot docs = snapshot.data.documents[index];
                        Timestamp time = docs.data['점검일'];
                        return Card(
                          color: docs.data['최종결과'] != "양호"
                              ? Colors.red.withOpacity(0.5)
                              : Colors.blue,
                          elevation: 5.0,
                          child: ListTile(
                            onTap: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => QualityResultDetail(
                                            qualityResult: docs,
                                          )));
                            },
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(child: Text('${docs.data['국소명']}')),
                                Text('${docs.data['점검자']}'),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('${time?.toDate() ?? 'noDate'}'),
                                  Text('${docs.data['최종결과']}')
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
