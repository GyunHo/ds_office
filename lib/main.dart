import 'package:ds_office/db/bloc.dart';
import 'package:ds_office/db/quality_check_bloc.dart';
import 'package:ds_office/screens/auth_page.dart';
import 'package:ds_office/screens/cloud_page.dart';
import 'package:ds_office/screens/main_widget_page.dart';
import 'package:ds_office/screens/quality_check_page.dart';
import 'package:ds_office/screens/report_page.dary.dart';
import 'package:ds_office/screens/sensingmap_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return MaterialApp(
            home: AuthPage(),
            debugShowCheckedModeBanner: false,
          );
        } else {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<Bloc>(create: (_) => Bloc()),
              ChangeNotifierProvider<QualityCheckBloc>(create: (_)=>QualityCheckBloc())
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              initialRoute: "main",
              routes: {
                "main": (context) => MainWidget(),
                "report": (context) => ReportPage(),
                "sensing": (context) => SensingMap(),
                "cloud": (context) => CloudPage(),
                "qualitycheck":(context)=>QualityCheckPage(),
              },
            ),
          );
        }
      },
    );
  }
}
