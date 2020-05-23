import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_midtrans_cc/flutter_midtrans_cc.dart';
import 'SuccessPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Midtrans CC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FlutterMidtransCCExample(),
    );
  }
}

class FlutterMidtransCCExample extends StatefulWidget {
  @override
  _FlutterMidtransCCExampleState createState() =>
      _FlutterMidtransCCExampleState();
}

class _FlutterMidtransCCExampleState extends State<FlutterMidtransCCExample> {
  TextEditingController ccNumberController;
  TextEditingController expiryDateController;
  TextEditingController expiryYearController;
  TextEditingController cvvController;
  FlutterMidtransCC midtransCC;

  List<Map> item_details = [
    {'id': 'item1', 'price': 15000, 'quantity': 1, 'name': 'roti bakar'}
  ];

  Map customer_details = {
    'first_name': 'John',
    'last_name': 'Doe',
    'email': 'johndoe@example.com',
    'phone': '08881112233344'
  };

  @override
  void initState() {
    midtransCC = FlutterMidtransCC('midtrans_production_url',
        'midtrans_staging_url', 'server_key', 'client_key',
        isProduction: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      child: ListView(
        children: <Widget>[
          TextFormField(
            controller: ccNumberController,
            autocorrect: false,
            autofocus: false,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: 'credit card number', labelText: 'cc number'),
          ),
          TextFormField(
            controller: expiryDateController,
            autocorrect: false,
            autofocus: false,
            keyboardType: TextInputType.number,
            decoration:
                InputDecoration(hintText: 'expiry date', labelText: 'exp date'),
          ),
          TextFormField(
            controller: expiryYearController,
            autocorrect: false,
            autofocus: false,
            keyboardType: TextInputType.number,
            decoration:
                InputDecoration(hintText: 'expiry year', labelText: 'exp year'),
          ),
          TextFormField(
            controller: cvvController,
            autocorrect: false,
            autofocus: false,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'cvv', labelText: 'cvv'),
          ),
          RaisedButton(
            child: Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.blue,
            onPressed: () {
              midtransCC
                  .getCreditCardToken(
                      ccNumberController.text,
                      expiryDateController.text,
                      expiryYearController.text,
                      cvvController.text)
                  .then((response) {
                print(response.statusCode);
                print(response.body);

                var extractedData = json.decode(response.body);

                if (response.statusCode == 200) {
                  if (extractedData['status_code'] == '200') {
                    midtransCC
                        .midtransCharge(extractedData['token_id'], '0x224s',
                            '15000', item_details, customer_details)
                        .then((response) {
                      var extractedData = json.decode(response.body);
                      print(response.statusCode);

                      if (response.statusCode == 201 ||
                          response.statusCode == 200) {
                        print(response.body);
                        if (extractedData['status_code'] == "201") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => midtransCC.webview3DS(
                                  transactionId:
                                      extractedData['transaction_id'],
                                  url: extractedData['redirect_url'],
                                  onClosePressed: () {
                                    Navigator.pop(context);
                                  },
                                  onCompleteRedirect: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SuccessPage(),
                                      ),
                                    );
                                  }),
                            ),
                          ).then((result) {
                            print(result);
                          });
                        }
                      } else {
                        print(response.body);
                      }
                    });
                  } else {
                    for (int i = 0;
                        i < extractedData['validation_messages'].length;
                        i++) {
                      var err = extractedData['validation_messages'].toString();

                      print(err);
                    }
                  }
                }
              });
            },
          )
        ],
      ),
    );
  }
}
