import 'package:ds_office/db/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_scanner/qr_scanner_camera.dart';
import 'package:kf_drawer/kf_drawer.dart';
import 'package:provider/provider.dart';

class ScanPage extends KFDrawerContent {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<Bloc>(context);
    List barCodes = bloc.getBarCodes().split('\n').toList();
    return Scaffold(
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 3,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              child: QRScannerCamera(
                onError: (context, error) => Text(
                  error.toString(),
                  style: TextStyle(color: Colors.red),
                ),
                qrCodeCallback: (code) {
                  bloc.setBarCodes(code);
                },
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0)),
                child: ListView.builder(
                    itemCount: barCodes.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {},
                        title: Text(barCodes[index]),
                      );
                    }),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.08,
              width: double.infinity,
              child: RaisedButton(
                child: Text("복사하기"),
                textColor: Colors.black,
                color: Colors.white,
                onPressed: () async {
                  await Clipboard.setData(
                          ClipboardData(text: bloc.getBarCodes()))
                      .whenComplete(() => Navigator.of(context).pop());
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.black, width: 2.0)),
              ),
            ),
          ),
          SizedBox(
            height: 8,
          )
        ],
      ),
    );
  }
}
