import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ReadyUiScreen extends StatefulWidget {
  const ReadyUiScreen({super.key});

  @override
  ReadyUiScreenState createState() => ReadyUiScreenState();
}

String _checkoutid = '';
String _resultText = '';

class ReadyUiScreenState extends State<ReadyUiScreen> {
  static const platform = MethodChannel('Hyperpay.demo.fultter/channel');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('READY UI'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _checkoutpage("credit");
                    },
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                        EdgeInsets.fromLTRB(22, 0, 22, 0),
                      ),
                    ),
                    child: Text('Credit Card'),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      _checkoutpage("mada");
                    },
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                        EdgeInsets.fromLTRB(22, 0, 22, 0),
                      ),
                    ),
                    child: Text('Mada'),
                  ),
                  SizedBox(height: 15),
                  if (Platform.isIOS)
                    ElevatedButton(
                      onPressed: () {
                        _checkoutpage("APPLEPAY");
                      },

                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.black),
                        padding: WidgetStateProperty.all(
                          EdgeInsets.fromLTRB(22, 0, 22, 0),
                        ),
                        textStyle: WidgetStateProperty.all(
                          TextStyle(color: Colors.white),
                        ),
                      ),
                      child: Text('APPLEPAY'),
                    ),
                  SizedBox(height: 35),
                  Text(
                    _resultText,
                    style: TextStyle(color: Colors.green, fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkoutpage(String type) async {
    //  requestCheckoutId();

    bool status;

    var myUrl = Uri.parse(
      'https://dev.hyperpay.com/hyperpay-demo/getcheckoutid.php',
    );

    // Uri myUrl = "http://dev.hyperpay.com/hyperpay-demo/getcheckoutid.php" as Uri;
    final response = await http.post(
      myUrl,
      headers: {'Accept': 'application/json'},
    );
    status = response.body.contains('error');

    var data = json.decode(response.body);

    if (status) {
      print('data : ${data["error"]}');
    } else {
      print('data : ${data["id"]}');
      _checkoutid = '${data["id"]}';

      String transactionStatus;
      try {
        final String result = await platform.invokeMethod(
          'gethyperpayresponse',
          {
            "type": "ReadyUI",
            "mode": "TEST",
            "checkoutid": _checkoutid,
            "brand": type,
          },
        );
        transactionStatus = result;
      } on PlatformException catch (e) {
        transactionStatus = "${e.message}";
      }

      if (transactionStatus != null ||
          transactionStatus == "success" ||
          transactionStatus == "SYNC") {
        print(transactionStatus);
        getpaymentstatus();
      } else {
        setState(() {
          _resultText = transactionStatus;
        });
      }
    }
  }

  Future<void> getpaymentstatus() async {
    bool status;

    Uri myUrl = Uri.parse(
      'https://dev.hyperpay.com/hyperpay-demo/getpaymentstatus.php?id=$_checkoutid',
    );
    final response = await http.post(
      myUrl,
      headers: {'Accept': 'application/json'},
    );
    status = response.body.contains('error');

    var data = json.decode(response.body);

    print("payment_status: ${data["result"].toString()}");

    setState(() {
      _resultText = data["result"].toString();
    });
  }
}
