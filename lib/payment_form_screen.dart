import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class PaymentFormScreen extends StatefulWidget {
  final String type;

  const PaymentFormScreen({super.key, required this.type});

  @override
  PaymentFormScreenState createState() => PaymentFormScreenState();
}

String _checkoutid = '';
String _resultText = '';
String _MadaRegexV =
    "4(0(0861|1757|7(197|395)|9201)|1(0685|7633|9593)|2(281(7|8|9)|8(331|67(1|2|3)))|3(1361|2328|4107|9954)|4(0(533|647|795)|5564|6(393|404|672))|5(5(036|708)|7865|8456)|6(2220|854(0|1|2|3))|8(301(0|1|2)|4783|609(4|5|6)|931(7|8|9))|93428)";
String _MadaRegexM =
    "5(0(4300|8160)|13213|2(1076|4(130|514)|9(415|741))|3(0906|1095|2013|5(825|989)|6023|7767|9931)|4(3(085|357)|9760)|5(4180|7606|8848)|8(5265|8(8(4(5|6|7|8|9)|5(0|1))|98(2|3))|9(005|206)))|6(0(4906|5141)|36120)|9682(0(1|2|3|4|5|6|7|8|9)|1(0|1))";
String _MadaHash = "";

class PaymentFormScreenState extends State<PaymentFormScreen> {
  static const platform = MethodChannel('Hyperpay.demo.fultter/channel');

  final _cardNumberText = TextEditingController();
  final _cardHolderText = TextEditingController();
  final _expiryMonthText = TextEditingController();
  final _expiryYearText = TextEditingController();
  final _CVVText = TextEditingController();
  final _STCPAYText = TextEditingController();

  final String _text = "";

  @override
  void dispose() async {
    // Clean up the controller when the widget is disposed.
    _cardNumberText.dispose();
    _cardHolderText.dispose();
    _expiryMonthText.dispose();
    _expiryYearText.dispose();
    _CVVText.dispose();
    _STCPAYText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Custom UI'),
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
                  Text("Checkout Page", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Card Number',
                      counter: Offstage(),
                    ),
                    controller: _cardNumberText,
                    maxLength: 16,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Holder Name',
                      counter: Offstage(),
                    ),
                    controller: _cardHolderText,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Expiry Month',
                            counter: Offstage(),
                          ),
                          controller: _expiryMonthText,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Expiry Year',
                            hintText: "ex : 2027",
                            counter: Offstage(),
                          ),
                          controller: _expiryYearText,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'CVV',
                      counter: Offstage(),
                    ),
                    controller: _CVVText,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                  ),
                  ElevatedButton(
                    onPressed: _pay,
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                        EdgeInsets.fromLTRB(22, 0, 22, 0),
                      ),
                    ),
                    child: Text('PAY'),
                  ),
                  SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: _paywithtoken,
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                        EdgeInsets.fromLTRB(22, 0, 22, 0),
                      ),
                      backgroundColor: WidgetStateProperty.all(
                        Colors.deepOrange,
                      ),
                    ),
                    child: Text('PAY with Test Card 1111 12/25'),
                  ),
                  SizedBox(height: 10),
                  if (Platform.isIOS)
                    ElevatedButton(
                      onPressed: _APPLEpay,
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
                  SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'STCPAY Number',
                      hintText: "05xxxxxxxx",
                      counter: Offstage(),
                    ),
                    controller: _STCPAYText,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                  ),
                  ElevatedButton(
                    onPressed: _STCPAYpay,
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                        EdgeInsets.fromLTRB(22, 0, 22, 0),
                      ),
                    ),
                    child: Text('STCPAY'),
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

  Future<void> _pay() async {
    if (_cardNumberText.text.isNotEmpty ||
        _cardHolderText.text.isNotEmpty ||
        _expiryMonthText.text.isNotEmpty ||
        _expiryYearText.text.isNotEmpty ||
        _CVVText.text.isNotEmpty) {
      _checkoutid = await _requestCheckoutId();

      print("typeeee${widget.type}");
      String transactionStatus;
      try {
        final String result = await platform
            .invokeMethod('gethyperpayresponse', {
              "type": "CustomUI",
              "checkoutid": _checkoutid,
              "mode": "TEST",
              "brand": widget.type,
              "card_number": _cardNumberText.text,
              "holder_name": _cardHolderText.text,
              "month": _expiryMonthText.text,
              "year": _expiryYearText.text,
              "cvv": _CVVText.text,
              "MadaRegexV": _MadaRegexV,
              "MadaRegexM": _MadaRegexM,
              "STCPAY": "disabled",
              "istoken": "false",
              "token": "",
            });
        transactionStatus = result;
      } on PlatformException catch (e) {
        transactionStatus = "${e.message}";
      }

      if (transactionStatus != null ||
          transactionStatus == "success" ||
          transactionStatus == "SYNC") {
        getpaymentstatus();
      } else {
        setState(() {
          _resultText = transactionStatus;
        });
      }
    } else {
      _showDialog();
    }
  }

  Future<void> _paywithtoken() async {
    if (_CVVText.text.isNotEmpty) {
      _checkoutid = await _requestCheckoutId();

      print("typeeee${widget.type}");
      String transactionStatus;
      try {
        final String result = await platform
            .invokeMethod('gethyperpayresponse', {
              "type": "CustomUI",
              "checkoutid": _checkoutid,
              "mode": "TEST",
              "brand": widget.type,
              "card_number": _cardNumberText.text,
              "holder_name": _cardHolderText.text,
              "month": _expiryMonthText.text,
              "year": _expiryYearText.text,
              "cvv": _CVVText.text,
              "MadaRegexV": _MadaRegexV,
              "MadaRegexM": _MadaRegexM,
              "STCPAY": "disabled",
              "istoken": "true",
              "token": "8ac7a4a0866e550201866f3755f90c9d",
            });
        transactionStatus = result;
      } on PlatformException catch (e) {
        transactionStatus = "${e.message}";
      }

      if (transactionStatus != null ||
          transactionStatus == "success" ||
          transactionStatus == "SYNC") {
        getpaymentstatus();
      } else {
        setState(() {
          _resultText = transactionStatus;
        });
      }
    } else {
      _showDialog();
    }
  }

  Future<void> _APPLEpay() async {
    _checkoutid = await _requestCheckoutId();

    print("typeeee${widget.type}");
    String transactionStatus;
    try {
      final String result = await platform.invokeMethod('gethyperpayresponse', {
        "type": "CustomUI",
        "checkoutid": _checkoutid,
        "mode": "TEST",
        "brand": "APPLEPAY",
        "card_number": _cardNumberText.text,
        "holder_name": _cardHolderText.text,
        "month": _expiryMonthText.text,
        "year": _expiryYearText.text,
        "cvv": _CVVText.text,
        "MadaRegexV": _MadaRegexV,
        "MadaRegexM": _MadaRegexM,
        "STCPAY": "disabled",
        "Amount": 1.00, // ex : 100.00 , 102.25 , 102.20
        "istoken": "false",
        "token": "",
      });
      transactionStatus = result;
    } on PlatformException catch (e) {
      transactionStatus = "${e.message}";
    }

    if (transactionStatus != null ||
        transactionStatus == "success" ||
        transactionStatus == "SYNC") {
      getpaymentstatus();
    } else {
      setState(() {
        _resultText = transactionStatus;
      });
    }
  }

  Future<void> _STCPAYpay() async {
    if (_STCPAYText.text.isNotEmpty) {
      _checkoutid = await _requestCheckoutId();
      print(_checkoutid);

      String transactionStatus = "";
      try {
        final String result = await platform
            .invokeMethod('gethyperpayresponse', {
              "type": "CustomUI",
              "checkoutid": _checkoutid,
              "mode": "TEST",
              "card_number": _cardNumberText.text,
              "holder_name": _cardHolderText.text,
              "month": _expiryMonthText.text,
              "year": _expiryYearText.text,
              "cvv": _CVVText.text,
              "STCPAY": "enabled",
              "istoken": "false",
              "token": "",
            });
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
    } else {
      _showDialog();
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

  Future<String> _requestCheckoutId() async {
    bool status;
    var myUrl = Uri.parse(
      'https://dev.hyperpay.com/hyperpay-demo/getcheckoutid.php',
    );

    final response = await http.post(
      myUrl,
      headers: {'Accept': 'application/json'},
    );
    status = response.body.contains('error');

    var data = json.decode(response.body);

    if (status) {
      print('data : ${data["error"]}');
      return "null";
    } else {
      return data['id'];
    }
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Alert!"),
          content: Text("Please fill all fields"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
