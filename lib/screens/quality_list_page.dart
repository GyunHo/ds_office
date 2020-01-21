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
  List<DocumentSnapshot> filterLists = List<DocumentSnapshot>();
  TextEditingController _textEditingController = TextEditingController();

  void queryFilter(QuerySnapshot snapshot, String query) {
    filterLists.clear();
    List<DocumentSnapshot> documentSnapshot = snapshot.documents;
    for (var i in documentSnapshot) {
      if (i.data["국소명"].toString().contains(query)) {
        filterLists.add(i);
      }
    }
  }

  Color switchColor(String res) {
    Color color;
    switch (res) {
      case "양호":
        color = Colors.white;
        break;
      case "불량":
        color = Colors.red.withOpacity(0.6);
        break;
      case "현장조치":
        color = Colors.yellow.withOpacity(0.6);
        break;
      case "조치완료":
        color = Colors.blue.withOpacity(0.6);
        break;
    }
    return color;
  }

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
          List<DocumentSnapshot> documents = _textEditingController.text.isEmpty
              ? snapshot.data?.documents
              : filterLists;

          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _textEditingController,
                  onChanged: (query) {
                    setState(() {
                      queryFilter(snapshot.data, query);
                    });
                  },
                  decoration: InputDecoration(
                      hintText: "국소명 검색",
                      labelText: "국소명",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.black))),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot docs = documents[index];
                        Timestamp time = docs.data['점검일'];
                        return Card(
                          color: switchColor(docs.data['최종결과']),
                          elevation: 5.0,
                          child: ListTile(
                            onLongPress: () async {
                              await ask().then((res) async {
                                if (res) {
                                  await Firestore.instance.runTransaction(
                                      (Transaction transaction) async {
                                    await transaction
                                        .delete(docs.reference)
                                        .whenComplete(() {
                                      return Scaffold.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text("삭제 완료"),
                                      ));
                                    }).catchError((e) {
                                      return Scaffold.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text("삭제 오류"),
                                      ));
                                    });
                                  });
                                } else {
                                  return null;
                                }
                              });
                            },
                            onTap: () async {
                              await Firestore.instance.runTransaction(
                                  (Transaction transaction) async {
                                await transaction
                                    .update(docs.reference, {"수정중": true});
                              });
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => QualityResultDetail(
                                            qualityResult: docs,
                                          ))).then((res) {
                                if (res ?? false) {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text("조치 완료 됐습니다."),
                                  ));
                                }
                              });
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

  Future<bool> ask() async {
    bool res = false;
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Text("삭제 하시겠습니까?"),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  color: Colors.grey,
                  child: Text(
                    "취소",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  color: Colors.red,
                  child: Text(
                    "삭제",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
              ),
            ],
          );
        }).then((result) {
      res = result ?? false;
    });

    return res;
  }
}
