import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ds_office/db/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kf_drawer/kf_drawer.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class TestDetailPage extends KFDrawerContent {
  final DocumentSnapshot snapshot;

  TestDetailPage(this.snapshot);

  @override
  _TestDetailPageState createState() => _TestDetailPageState();
}

class _TestDetailPageState extends State<TestDetailPage> {
  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
  TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    _controller.text = widget.snapshot.data['document'] ?? '내용없음';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<Bloc>(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '상세페이지',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              Expanded(
                  child: TextFormField(
                decoration: InputDecoration(border: InputBorder.none),
                maxLines: null,
                controller: _controller,
              )),
              buttons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buttons() {
    final bloc = Provider.of<Bloc>(context);
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        ButtonTheme(
          minWidth: size.width * 0.4,
          height: size.height * 0.07,
          child: RaisedButton(
            color: Colors.black,
            elevation: 10.0,
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              '내용복사',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _controller.text))
                  .whenComplete(() {
                globalKey.currentState.showSnackBar(SnackBar(
                  content: Text('복사완료'),
                  duration: Duration(milliseconds: 500),
                ));
              });
            },
          ),
        ),
        ButtonTheme(
          minWidth: size.width * 0.4,
          height: size.height * 0.07,
          child: RaisedButton(
            color: Colors.black,
            elevation: 10.0,
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              '내용수정',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              if (widget.snapshot.data['document'] != _controller.text) {
                bloc
                    .updateReport(widget.snapshot, _controller.text)
                    .whenComplete(() {
                  String overMessage = '////내용수정////\n' + _controller.text;
                  bloc.sendTeamRoom(overMessage);
                  Navigator.of(context).pop('수정완료');
                }).catchError((e) {
                  _isLoading = false;
                  globalKey.currentState.showSnackBar(SnackBar(
                    duration: Duration(milliseconds: 500),
                    content: Text('다시 시도해 주세요'),
                  ));
                });
              } else {
                Navigator.of(context).pop('수정완료');
              }
            },
          ),
        ),
      ],
    );
  }
}
