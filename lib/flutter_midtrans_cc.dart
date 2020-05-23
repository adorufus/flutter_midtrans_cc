library flutter_midtrans_cc;

import 'package:flutter/material.dart';

import 'src/Webview3DS.dart';

import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;

/// A Calculator.
class FlutterMidtransCC {
  /// enter your production url
  final String midtrans_production_url;

  /// enter your staging url
  final String midtrans_staging_url;

  /// server_key can be found on your midtrans dashboard
  final String server_key;

  /// client_key can be found on your midtrans dashboard
  final String client_key;

  /// if true, production url will be used
  /// if false, staging url will be used
  final bool isProduction;

  FlutterMidtransCC(this.midtrans_production_url, this.midtrans_staging_url,
      this.server_key, this.client_key,
      {this.isProduction = true});

  /// generate credit card token, so we can access 3DS
  ///
  /// this also handle fraud detection and other error
  Future<http.Response> getCreditCardToken(String cardNumber, String expiryDate,
      String expiryYear, String cvv) async {
    String baseUrl =
        isProduction == true ? midtrans_production_url : midtrans_staging_url;

    String url = baseUrl +
        'v2/token?client_key=$client_key&card_number=$cardNumber&card_exp_month=$expiryDate&card_exp_year=20$expiryYear&card_cvv=$cvv';

    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': base64.encode(utf8.encode(server_key + ':'))
    });

    return response;
  }

  Widget webview3DS({String transaction_id, String url, Function onClosePressed, Function onCompleteRedirect}) {
    String baseUrl =
        isProduction == true ? midtrans_production_url : midtrans_staging_url;
    return Webview3DS(
      midtransBaseUrl: baseUrl,
      serverKey: server_key,
      onClosePressed: onClosePressed,
      onCompletedNavigation: onCompleteRedirect,
      transaction_id: transaction_id,
      url: url,
    );
  }

  /// Do charge on your transaction
  ///
  /// how to call midtransCharge:
  ///
  /// List<Map> item_details = [{
  ///   'id': yourCustomPaymentId,
  ///   'price': yourFinalPrice,
  ///   'quantity': yourQuantity,
  ///   'name': yourCustomItemName
  /// },];
  ///
  /// Map customer_details = {
  ///   'first_name': customerFirstName,
  ///   'last_name': customerLastName,
  ///   'email': customerEmail,
  ///   'phone': customerPhone
  /// }
  ///
  /// midtransCharge(yourTokenId, yourOrderId, yourGrossAmount, item_details, customer_details);
  ///
  ///
  Future<http.Response> midtransCharge(String tokenId, String order_id,
      String gross_amount, List<Map> item_details, Map customer_details) async {
    String baseUrl =
        isProduction == true ? midtrans_production_url : midtrans_staging_url;

    String url = baseUrl + 'v2/charge';
    var encodingBody = json.encode({
      'payment_type': 'credit_card',
      'transaction_details': {
        'order_id': order_id,
        'gross_amount': gross_amount
      },
      'credit_card': {"token_id": tokenId, "authentication": true},
      'item_details': item_details,
      'customer_details': customer_details
    });

    final response = await http.post(url, body: encodingBody, headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': base64.encode(utf8.encode(server_key + ':'))
    });

    return response;
  }
}
