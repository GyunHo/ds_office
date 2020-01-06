import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ds_office/db/quality_check_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';

class QualityCheckPage extends StatefulWidget {
  @override
  _QualityCheckPageState createState() => _QualityCheckPageState();
}

class _QualityCheckPageState extends State<QualityCheckPage> {
  static GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  List<String> _check;
  Map<String, dynamic> data = {};
  String name;
  String uid;

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      uid = user.uid;
      QualityCheckBloc().getUserName(uid).then((username) {
        name = username;
      });
    });

    QualityCheckBloc().getJson().then((Map<String, String> json) {
      List<String> list = json.values
          .toList()[0]
          .split('\n')
          .where((val) => val != '')
          .toList();
      for (var i in list) {
        if (data[i] == null) {
          data[i] = {'점검결과': '양호', '기타의견': '없음'};
        }
      }
      setState(() {
        _check = list;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<QualityCheckBloc>(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            '품질점검',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                onPressed: () async {
                  _globalKey.currentState.save();
                  data['점검일'] = DateTime.now();
                  data['점검자'] = name;

                  await bloc.addCheckList(data).then((res) {
                    if (res == "성공") {
                      Navigator.pop(context, true);
                    } else {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text('저장에 실패 하였습니다.'),
                      ));
                    }
                  });
                },
                child: Text('저장'),
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _globalKey,
            child: _check == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          onSaved: (val) {
                            if (val.isNotEmpty) {
                              data['국소명'] = val;
                            } else {
                              data['국소명'] = '국소명 없음';
                            }
                          },
                          decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.red, width: 5.0),
                                  borderRadius: BorderRadius.circular(10.0)),
                              hintText: "국소명 입력",
                              labelText: "국소명"),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                            itemCount: _check.length,
                            itemBuilder: (BuildContext context, int index) {
                              Map<String, dynamic> maps =
                                  data['${_check[index]}'];
                              return Card(
                                margin: EdgeInsets.only(bottom: 10.0),
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: ListTile(
                                  title: Text('${_check[index]}'),
                                  subtitle: Column(
                                    children: <Widget>[
                                      CustomRadioButton(
                                        buttonColor: Colors.white,
                                        selectedColor: Colors.redAccent,
                                        buttonLables: ['양호', '불량', '조치'],
                                        buttonValues: ['양호', '불량', '조치'],
                                        radioButtonValue: (val) {
                                          maps['점검결과'] = val;
                                        },
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10.0),
                                        child: TextFormField(
                                          onSaved: (val) {
                                            if (val.isNotEmpty) {
                                              maps['기타의견'] = val;
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: "기타 또는 불량 의견",
                                            labelText: "의견 작성",
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
          ),
        ));
  }
}
