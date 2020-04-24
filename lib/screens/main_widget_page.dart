import 'package:ds_office/screens/test_list_page.dart';
import 'package:ds_office/screens/quality_list_page.dart';
import 'package:ds_office/screens/test_report_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kf_drawer/kf_drawer.dart';

import 'build_list_page.dart';

class MainWidget extends StatefulWidget {
  MainWidget({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> with TickerProviderStateMixin {
  KFDrawerController _drawerController;

  @override
  void initState() {
    super.initState();
    _drawerController = KFDrawerController(
      initialPage: TestListPage(),
      items: [
        KFDrawerItem.initWithPage(
          text: Text('시험개통결과', style: TextStyle(color: Colors.white)),
          icon: Icon(Icons.cloud, color: Colors.white),
          page: TestListPage(),
        ),
        KFDrawerItem.initWithPage(
          text: Text('품질점검', style: TextStyle(color: Colors.white)),
          icon: Icon(Icons.receipt, color: Colors.white),
          page: QualityListPage(),
        ),
        KFDrawerItem.initWithPage(
          text: Text('시설내역서', style: TextStyle(color: Colors.white)),
          icon: Icon(Icons.receipt, color: Colors.white),
          page: BuildListPage(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KFDrawer(
//        borderRadius: 0.0,
//        shadowBorderRadius: 0.0,
//        menuPadding: EdgeInsets.all(0.0),
//        scrollable: true,
        controller: _drawerController,
//        header: Align(
//          alignment: Alignment.centerLeft,
//          child: Container(
//            padding: EdgeInsets.symmetric(horizontal: 16.0),
//            width: MediaQuery.of(context).size.width * 0.6,
//            child: Image.asset(
//              'assets/logo.png',
//              alignment: Alignment.centerLeft,
//            ),
//          ),
//        ),
        footer: KFDrawerItem(
          text: Text(
            '로그아웃',
            style: TextStyle(color: Colors.white),
          ),
          icon: Icon(
            Icons.input,
            color: Colors.white,
          ),
          onPressed: () {
            FirebaseAuth.instance.signOut();
          },
        ),
        decoration: BoxDecoration(color: Colors.black87),
      ),
    );
  }
}
