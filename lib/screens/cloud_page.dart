import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ds_office/db/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kf_drawer/kf_drawer.dart';
import 'package:provider/provider.dart';

class CloudPage extends KFDrawerContent {
  @override
  _CloudPageState createState() => _CloudPageState();
}

class _CloudPageState extends State<CloudPage> {
  String userId;

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      setState(() {
        userId = user.uid;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<Bloc>(context);
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              bloc.addReport('test', '시험입니다.');

//              FirebaseUser _user = await FirebaseAuth.instance.currentUser();
//              String uid = _user.uid;
//              Firestore.instance
//                  .runTransaction((Transaction transaction) async {
//                CollectionReference reference =
//                    Firestore.instance.collection('documents');
//
//                await reference.add(
//                    {'title': '', 'editing': false, 'score': 0, 'uid': uid});
//              });
            },
          )
        ],
        centerTitle: true,
        title: Text('클라우드'),
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
        stream: Firestore.instance.collection('documents').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return FirestoreListView(documents: snapshot.data.documents);
        },
      ),
    );
  }
}

class FirestoreListView extends StatelessWidget {
  final List<DocumentSnapshot> documents;

  const FirestoreListView({Key key, this.documents}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: documents.length,
      itemExtent: 120.0,
      itemBuilder: (BuildContext context, int index) {
        String title = documents[index].data['title'].toString();

        return ListTile(
          title: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: Colors.black),
            ),
            padding: EdgeInsets.all(5.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: !documents[index].data['editing']
                      ? Text(title)
                      : TextFormField(
                          initialValue: title,
                          onFieldSubmitted: (String val) {
                            Firestore.instance.runTransaction(
                                (Transaction transaction) async {
                              DocumentSnapshot snapshot = await transaction
                                  .get(documents[index].reference);
                              await transaction.update(snapshot.reference, {
                                'title': val,
                                'editing': !documents[index].data['editing']
                              });
                            });
                          },
                        ),
                ),
              ],
            ),
          ),
          onTap: () => Firestore.instance
              .runTransaction((Transaction transaction) async {
            DocumentSnapshot snapshot =
                await transaction.get(documents[index].reference);

            await transaction
                .update(snapshot.reference, {'editing': !snapshot['editing']});
          }),
        );
      },
    );
  }
}
