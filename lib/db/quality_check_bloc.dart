import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;


class QualityCheckBloc extends ChangeNotifier{


  String _spreadSheetUrl =
      'https://spreadsheets.google.com/feeds/list/1leg0EydCOkzSMoDgWe9ac9PYLK_msjgrT9sV9SQFkjk/od6/public/values?alt=json';
  getSheetUrl()=>_spreadSheetUrl;



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