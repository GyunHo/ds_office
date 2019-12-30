import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Bloc extends ChangeNotifier {
  final _inComingUrl =
      'https://teamroom.nate.com/api/webhook/bdb7d4dc/fspw77bjrmRMwhS3ioE6j3NZ';
  final _spreadSheetUrl =
      'https://spreadsheets.google.com/feeds/list/1EdkkgNyOy0CgA9R09TuANll2_fWYPoKjAfiB79ynpsQ/od6/public/values?alt=json';

  sendMassage(String massage) async {
    http.Response response = await http.post(_inComingUrl,body: {'content':massage});
    return response.statusCode;
  }

  Future<Map<String, String>> getJson() async {
    http.Response response = await http.get(_spreadSheetUrl);
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
