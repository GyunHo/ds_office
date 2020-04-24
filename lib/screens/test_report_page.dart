import 'package:ds_office/db/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kf_drawer/kf_drawer.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class TestReportPage extends KFDrawerContent {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<TestReportPage> {
  TextEditingController _textEditingController = TextEditingController();
  Future<FirebaseUser> user = FirebaseAuth.instance.currentUser();
  bool _isLoading = false;
  Map<String, String> work;
  String title = '';

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<Bloc>(context);

    return  Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _textEditingController.clear();
                    title = '';
                  }),
            ],
            backgroundColor: Colors.black,
            title: Text(
              "보고서 작성",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: ModalProgressHUD(
            inAsyncCall: _isLoading,
            child: FutureBuilder(
              future: bloc.getJson(),
              builder: (context, AsyncSnapshot<Map> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Container(
                      padding: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.black, width: 2.0)),
                      child: Column(
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                      color: Colors.black, width: 2.0)),
                              child: DropdownButton(
                                underline: SizedBox(),
                                isExpanded: true,
                                iconEnabledColor: Colors.grey,
                                hint: Text("보고서 유형 선택"),
                                items: snapshot.data.keys.map((title) {
                                  return DropdownMenuItem(
                                      child: Text(title), value: title);
                                }).toList(),
                                onChanged: (value) {
                                  title = value;
                                  _textEditingController.text =
                                      snapshot.data[value];
                                },
                              )),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          Expanded(
                            child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                        color: Colors.black, width: 2.0)),
                                child: TextFormField(
                                  controller: _textEditingController,
                                  maxLines: null,
                                  decoration:
                                      InputDecoration(border: InputBorder.none),
                                )),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: InkWell(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(
                                              text: _textEditingController.text))
                                          .whenComplete(() {
                                        Scaffold.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text('복사완료'),
                                          duration: Duration(milliseconds: 500),
                                        ));
                                      });
                                    },
                                    child: Card(
                                      child: SizedBox(
                                        child: Center(
                                          child: Text("내용 복사"),
                                        ),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.08,
                                      ),
                                      elevation: 5.0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          side: BorderSide(
                                              color: Colors.black, width: 2.0)),
                                    )),
                              ),
                              Flexible(
                                child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      bloc
                                          .addReport(
                                              title: title == ""
                                                  ? "분류없음"
                                                  : title ?? '분류없음',
                                              document:
                                                  _textEditingController.text ??
                                                      '내용없음')
                                          .whenComplete(() {
                                        Navigator.of(context).pop('저장완료');
                                        bloc.sendTeamRoom(
                                            _textEditingController.text);
                                      }).catchError((e) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        Scaffold.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text('다시 시도해 주세요'),
                                          duration: Duration(milliseconds: 500),
                                        ));
                                        print(e);
                                      });
                                    },
                                    child: Card(
                                      child: SizedBox(
                                        child: Center(
                                          child: Text("저장/전송"),
                                        ),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.08,
                                      ),
                                      elevation: 5.0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          side: BorderSide(
                                              color: Colors.black, width: 2.0)),
                                    )),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ));

  }
}
