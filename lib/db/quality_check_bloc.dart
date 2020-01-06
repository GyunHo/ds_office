import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class QualityCheckBloc extends ChangeNotifier {
  String _spreadSheetUrl =
      'https://spreadsheets.google.com/feeds/list/1leg0EydCOkzSMoDgWe9ac9PYLK_msjgrT9sV9SQFkjk/od6/public/values?alt=json';

  getSheetUrl() => _spreadSheetUrl;

  Future<String> getUserName(String uid) async {
    DocumentSnapshot snapshot =
        await Firestore.instance.collection('users').document(uid).get();

    return snapshot.data['name'] ?? "이름없음";
  }

  Future<String> addCheckList(Map<String, dynamic> data) async {
    Map<String, dynamic> dummy = data;
    List<dynamic> vals = dummy.values.toList();

    for (var i in vals) {
      try {
        if (i['점검결과'] != '양호') {
          dummy['최종결과'] = '불량';
          break;
        } else {
          dummy['최종결과'] = '양호';
        }
      } catch (e) {
        print(e);
      }
    }
    String res = '';
    CollectionReference collectionReference =
        Firestore.instance.collection('checklist');

    await collectionReference
        .document()
        .setData(dummy)
        .whenComplete(() => res = "성공")
        .catchError((e) {
      res = "실패";
    });
    return res;
  }

  Future<Map<String, String>> getJson() async {
    http.Response response = await http.get(getSheetUrl());
    Map json = jsonDecode(response.body);
    List doc = json['feed']['entry'];
    List title = json['feed']['entry'][0].keys.toList().sublist(6);
    Map<String, String> res = {};
    for (String i in title) {
      String dummy = "";
      for (var x in doc) {
        if (x[i]['\$t'] != "") {
          dummy += "${x[i]['\$t']}\n";
        }
      }
      res[i.split("\$")[1]] = dummy;
    }
    return res;
  }
}
