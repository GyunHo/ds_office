import 'package:kf_drawer/kf_drawer.dart';
import 'package:flutter/material.dart';

class BuildReport extends KFDrawerContent {
  @override
  _BuildReportState createState() => _BuildReportState();
}

class _BuildReportState extends State<BuildReport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
    );
  }
}
