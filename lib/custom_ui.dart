import 'package:flutter/material.dart';
import 'package:hyperpay_flutter/payment_form_screen.dart';

class CustomUiScreen extends StatefulWidget {
  const CustomUiScreen({super.key});

  @override
  CustomUiScreenState createState() => CustomUiScreenState();
}

String _checkoutid = '';
String _resultText = '';
String _MadaRegexV = "";
String _MadaRegexM = "";
String _MadaHash = "";

class CustomUiScreenState extends State<CustomUiScreen> {
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
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PaymentFormScreen(type: "credit"),
                        ),
                      );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentFormScreen(type: "mada"),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                        EdgeInsets.fromLTRB(22, 0, 22, 0),
                      ),
                    ),
                    child: Text('Mada'),
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
