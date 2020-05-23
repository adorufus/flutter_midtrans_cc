import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class Webview3DS extends StatefulWidget {
  final String transaction_id;
  final String url;
  final String midtransBaseUrl;
  final String serverKey;
  final Function onClosePressed;
  final Function onCompletedNavigation;

  const Webview3DS({Key key, this.transaction_id, this.url, this.onClosePressed, this.midtransBaseUrl, this.onCompletedNavigation, this.serverKey}) : super(key: key);
  @override
  _Webview3DSState createState() => _Webview3DSState();
}

class _Webview3DSState extends State<Webview3DS> {
  bool isLoading = false;
  String headerText = '';
  Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          headerText,
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 13),
            child: isLoading == true
                ? CircularProgressIndicator(backgroundColor: Colors.blue,)
                : Container(),
          )
        ],
        leading: GestureDetector(
          onTap: widget.onClosePressed,
          child: Icon(
            Icons.close,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: widget.url,
          onPageStarted: (val) {
            print(val);

            setState(() {
              headerText = val;
              if (headerText.startsWith(
                  'https://api.veritrans.co.id/v2/token/rba/callback')) {
                getTransactStatus().then((response) {
                  var extractedData = json.decode(response.body);

                  if (response.statusCode == 200) {
                    if (extractedData['channel_response_code'] == '0') {
                      widget.onCompletedNavigation();
                    } else {
                      if (extractedData['transaction_status'] == 'deny' &&
                          extractedData['fraud_status'] == "deny") {
                        Navigator.pop(context,
                            "[fraud card] Card denied by system, please try another card");
                      } else {
                        Navigator.pop(
                            context, extractedData['channel_response_message']);
                      }
                    }
                  } else {
                    print(extractedData);
                  }
                });
              }
              isLoading = true;
            });
          },
          onPageFinished: (val) {
            setState(() {
              isLoading = false;
            });
          },
          onWebViewCreated: (WebViewController controller) {
            _controller.complete(controller);

            setState(() {
              isLoading = false;

              controller.getTitle().then((value) {
                setState(() {
                  headerText = value;
                });
              });
              print(controller.currentUrl());
            });
          },
        ),
      ),
    );
  }

  Future<http.Response> getTransactStatus() async {
    String url =
        widget.midtransBaseUrl + 'v2/${widget.transaction_id}/status';

    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': base64.encode(utf8.encode(widget.serverKey + ':'))
    });

    print(response.statusCode);
    print(response.body);

    return response;
  }
}