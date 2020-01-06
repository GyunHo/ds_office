import 'package:ds_office/db/quality_check_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';

class QualityCheckPage extends StatefulWidget {
  @override
  _QualityCheckPageState createState() => _QualityCheckPageState();
}

class _QualityCheckPageState extends State<QualityCheckPage> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final blocs = Provider.of<QualityCheckBloc>(context);
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
      ),
      body: Form(
        key: _globalKey,
        child: FutureBuilder(
          future: blocs.getJson(),
          builder: (BuildContext context,
              AsyncSnapshot<Map<String, String>> snapshot) {
            if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.active ||
                snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            var title = snapshot.data.keys.toList()[0];
            return ListView.builder(
                itemCount: snapshot.data[title].split('\n').toList().length,
                itemBuilder: (BuildContext context, int index) {
                  List _list = snapshot.data[title].split('\n').toList();


                  return Card(

                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),side: BorderSide(color: Colors.black)),
                    child: ListTile(
                        title: Text('${_list[index]}'),
                        subtitle: Column(
                          children: <Widget>[
                            CustomRadioButton(
                              selectedColor: Colors.blueAccent,
                              buttonColor: Colors.white,
                              buttonValues: ['양호', '불량', '조치'],
                              buttonLables: ['양호', '불량', '조치'],
                              radioButtonValue: (val) {
                                print(val);
                              },
                            ),
                            TextFormField(
                              maxLines: 3,

                              decoration: InputDecoration(
                                  hintText: "기타 또는 불량 의견",
                                  labelText: "기타의견",
                                  border: InputBorder.none),
                            )
                          ],
                        )),
                  );
                });
          },
        ),
      ),
    );
  }
}
