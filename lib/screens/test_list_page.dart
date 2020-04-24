import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ds_office/db/bloc.dart';
import 'package:ds_office/screens/test_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:kf_drawer/kf_drawer.dart';
import 'package:provider/provider.dart';

class TestListPage extends KFDrawerContent {
  @override
  _CloudPageState createState() => _CloudPageState();
}

class _CloudPageState extends State<TestListPage> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<Bloc>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () async {
          await Navigator.pushNamed(context, 'testreport').then((res) {
            if (res != null) {
              Scaffold.of(context).showSnackBar(SnackBar(
                duration: Duration(milliseconds: 500),
                content: Text(res.toString()),
              ));
            }
          });
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text('시험개통결과'),
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
            .collection('documents')
            .orderBy('updatedate', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          bloc.setDocumentSnapshot(snapshot.data.documents);
          return FirestoreListView();
        },
      ),
    );
  }
}

class FirestoreListView extends StatefulWidget {
  @override
  _FirestoreListViewState createState() => _FirestoreListViewState();
}

class _FirestoreListViewState extends State<FirestoreListView> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<Bloc>(context);
    List<DocumentSnapshot> _list = _controller.text.isEmpty
        ? bloc.getDocumentSnapshot()
        : bloc.getQueryList();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _controller,
            onChanged: (query) {
              bloc.setQueryList(query);
            },
            decoration: InputDecoration(
                hintText: "검색",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.black, width: 4.0))),
          ),
          SizedBox(
            height: 10.0,
          ),
          Flexible(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: ListView.builder(
                itemCount: _list.length,
                itemBuilder: (BuildContext context, int index) {
                  String doc = _list[index].data['document'].toString();
                  return InkWell(
                    onLongPress: () async {
                      await Firestore.instance
                          .runTransaction((Transaction transaction) {
                        return transaction.delete(_list[index].reference);
                      });
                    },
                    onTap: () async {
                      await Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) =>
                                  TestDetailPage(_list[index])))
                          .then((res) {
                        if (res != null) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            duration: Duration(milliseconds: 500),
                            content: Text(res.toString(),),
                          ));
                        }
                      });
                    },
                    child: Card(
                      elevation: 3.0,
                      child: Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Container(child: Text(doc.toString())),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
