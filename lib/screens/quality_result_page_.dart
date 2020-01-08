import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ds_office/db/quality_check_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';

class QualityResultDetail extends StatefulWidget {
  final DocumentSnapshot qualityResult;

  const QualityResultDetail({Key key, this.qualityResult}) : super(key: key);

  @override
  _QualityResultDetailState createState() => _QualityResultDetailState();
}

class _QualityResultDetailState extends State<QualityResultDetail> {
  String name,uid;
  Map<String, dynamic> check = Map();
  Map<String, dynamic> info = Map();

  Color color(String res) {
    Color color;
    switch (res) {
      case "양호":
        color = Colors.white;
        break;
      case "불량":
        color = Colors.red.withOpacity(0.6);
        break;
      case "조치":
        color = Colors.yellow.withOpacity(0.6);
        break;
      case "조치료":
        color = Colors.blue.withOpacity(0.6);
        break;
    }
    return color;
  }

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      uid = user.uid;
      QualityCheckBloc().getUserName(uid).then((username) {
        name = username;
      });
    });


    for (var i in widget.qualityResult.data.keys.toList()) {
      if (widget.qualityResult.data[i] is Map) {
        check[i] = widget.qualityResult.data[i];
      } else {
        info[i] = widget.qualityResult.data[i];
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List checkTitles = check.keys.toList();
    List infotitles = check.keys.toList();
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                print(info);
                print(name);
              },
            )
          ],
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            widget.qualityResult.data['국소명'].toString(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(info['점검자']),
              Expanded(
                child: ListView.builder(
                    itemCount: checkTitles.length,
                    itemBuilder: (BuildContext context, int index) {
                      String res = check[checkTitles[index]]['점검결과'];
                      return Card(
                        elevation: 5.0,
                        color: color(res),
                        child: ListTile(
                            title: Text('${checkTitles[index]}'),
                            subtitle: Column(
                              children: <Widget>[
                                Card(
                                  child:
                                      Text(check[checkTitles[index]]['기타의견']),
                                ),
                                RadioButtonGroup(
                                  orientation:
                                      GroupedButtonsOrientation.HORIZONTAL,
                                  labels: ['양호', '불량', '조치', '조치완료'],
                                  picked: res,
                                  onSelected: (val) {
                                    Firestore.instance.runTransaction(
                                        (Transaction transaction) async {
                                      Map ct = check[checkTitles[index]];
                                      ct['점검결과'] = val;

                                      await transaction.update(
                                          widget.qualityResult.reference,
                                          {checkTitles[index]: ct});
                                    });

                                    setState(() {
                                      check[checkTitles[index]]['점검결과'] = val;
                                    });
                                  },
                                ),
                              ],
                            )),
                      );
                    }),
              ),
            ],
          ),
        ));
    ;
  }
}
