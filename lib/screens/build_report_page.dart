import 'dart:convert';

import 'package:animated_multi_select/animated_multi_select.dart';
import 'package:flutter/cupertino.dart';
import 'package:kf_drawer/kf_drawer.dart';
import 'package:flutter/material.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:http/http.dart' as http;

class BuildReport extends KFDrawerContent {
  @override
  _BuildReportState createState() => _BuildReportState();
}

class _BuildReportState extends State<BuildReport> {
  String url =
      'https://spreadsheets.google.com/feeds/cells/1mWP4vOOjxK5aZNJFsTRzoUURXVISkQcTUC0FY7ym17I/1/public/full?alt=json';
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  Map<String, Widget> widgetList = {};

  List<String> element;
  List<String> materials;
  List<List> selectedMaterials = [];
  List<List> selectedMaterialsControllers = [];
  Map<String, dynamic> soloData = {};

  @override
  void initState() {
    getJson().then((re) {
      for (var i in element) {
        widgetList[i] = Text(
          i.toString(),
          overflow: TextOverflow.fade,
        );
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        focusColor: Colors.grey,
        child: Text(
          '추가',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          addMaterials();
        },
      ),
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              onPressed: () {},
              child: Text(
                '저장',
              ),
              color: Colors.white,
            ),
          )
        ],
        centerTitle: true,
        title: Text(
          '시설내역서',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: widget.onMenuPressed,
          icon: Icon(Icons.menu),
        ),
      ),
      body: element == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.black)),
                padding: EdgeInsets.all(8.0),
                child: Form(
                  key: _formkey,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: textThing("국소명", val: true),
                            flex: 2,
                          ),
                          Flexible(
                            child: textThing("시설자", val: true),
                            flex: 1,
                          ),
                        ],
                      ),
                      MultiSelectChip(
                        reverseScroll: false,
                        color: Colors.greenAccent,
                        width: 80,
                        height: 50,
                        borderRadius: BorderRadius.circular(10),
                        borderWidth: 2,
                        mainList: element,
                        onSelectionChanged: (selectedList) {},
                        widgetList: widgetList,
                        initialSelectionList: [],
                      ),
                      Expanded(
                        child: ListView.separated(
                            shrinkWrap: true,
                            separatorBuilder: (context, index) {
                              return Divider(
                                color: Colors.red,
                                thickness: 2.0,
                              );
                            },
                            itemCount: selectedMaterials.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                child: selectItem(index),
                                onLongPress: () {
                                  deleteMaterials(index);
                                },
                              );
                            }),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget selectItem(int index) {
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        title: Text(selectedMaterials[index][0].toString()),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (inindex) {
            return Expanded(
                child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: TextFormField(
                controller: selectedMaterialsControllers[index][inindex],
                keyboardType: TextInputType.numberWithOptions(),
                onSaved: (val) {
                  selectedMaterials[index][inindex + 1] = val;
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    labelText: "${inindex + 1}번",
                    hintText: "${inindex + 1}번"),
              ),
            ));
          }),
        ),
      ),
    );
  }

  addMaterials() async {
    await SelectDialog.showModal(context, items: materials, onChange: (val) {
      if (val != '' || val != null) {
        List mat = List.generate(5, (index) {
          return '';
        });
        List<TextEditingController> con = List.generate(5, (index) {
          return TextEditingController();
        });
        selectedMaterialsControllers.add(con);
        mat[0] = val;
        setState(() {
          selectedMaterials.add(mat);
        });
      }
    });
  }

  deleteMaterials(int index) {
    setState(() {
      selectedMaterials.removeAt(index);
      selectedMaterialsControllers.removeAt(index);
    });
  }

  Widget textThing(String title, {bool val = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.0),
      child: TextFormField(
        onChanged: (str) {
          soloData[title] = str;
        },
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            hintText: title,
            labelText: title),
        autovalidate: val,
        validator: (value) {
          if (val && value.isEmpty) {
            return "$title 필수!";
          } else {
            return null;
          }
        },
        onSaved: (value) {},
      ),
    );
  }

  Future getJson() async {
    http.Response response = await http.get(url);
    Map<dynamic, dynamic> jsonData = jsonDecode(response.body);
    List<dynamic> data = jsonData['feed']['entry'];
    List<String> checkData = [];
    List<String> materialData = [];
    for (var i in data) {
      if (i['gs\$cell']['col'] == '2') {
        checkData.add(i['gs\$cell']['inputValue'].toString());
      }
      if (i['gs\$cell']['col'] == '1') {
        materialData.add(i['gs\$cell']['inputValue'].toString());
      }
    }
    setState(() {
      element = checkData;
      materials = materialData;
    });
  }
}
