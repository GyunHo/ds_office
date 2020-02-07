import 'package:kf_drawer/kf_drawer.dart';
import 'package:flutter/material.dart';
import 'package:find_dropdown/find_dropdown.dart';
class BuildReport extends KFDrawerContent {
  @override
  _BuildReportState createState() => _BuildReportState();
}

class _BuildReportState extends State<BuildReport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: SingleChildScrollView(
        child: Form(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title:  FindDropdown<String>(onChanged: (val){},items:[] ,

                    searchBoxDecoration: InputDecoration(
                      hintText: "자재 검색"
                    ),

                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
