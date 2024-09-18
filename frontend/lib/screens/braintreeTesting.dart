import 'package:flutter/material.dart';
import 'package:flutter_braintree/flutter_braintree.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _cardNumber;
  String? _expiryDate;
  String? _cardType;

  Future<String> getClientToken() async {
    final response =
        await http.get(Uri.parse('http://10.10.2.195:5000/api/client_token'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['clientToken'];
    } else {
      throw Exception('Failed to fetch client token');
    }
  }

  Future<void> addCard() async {
    final clientToken = await getClientToken();
    final request = BraintreeDropInRequest(
      tokenizationKey: clientToken,
      collectDeviceData: true,
      paypalRequest: BraintreePayPalRequest(
        amount: '10.00',
        displayName: 'Your Company',
      ),
      cardEnabled: true,
    );

    final result = await BraintreeDropIn.start(request);
    if (result != null && result.paymentMethodNonce != null) {
      setState(() {
        _cardNumber = result.paymentMethodNonce.description;
        _expiryDate =
            "12/24"; // Placeholder, real expiry date is not provided by BraintreeDropIn
        _cardType = result.paymentMethodNonce.typeLabel;
      });

      final userUUID = "example-uuid"; // Replace this with the actual user UUID
      final maskedCardNumber =
          _cardNumber!.replaceAll(RegExp(r'.{12}'), '**** **** **** ');

      // Send payment method nonce and additional details to your server
      final response = await http.post(
        Uri.parse('http://10.10.2.195:5000/api/save_card'),
        body: jsonEncode({
          'paymentMethodNonce': result.paymentMethodNonce.nonce,
          'userUUID': userUUID,
          'maskedCardNumber': maskedCardNumber,
          'expiryDate': _expiryDate,
          'cardType': _cardType,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print('Card saved successfully!');
      } else {
        print('Failed to save card.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Braintree Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: addCard,
              child: Text('Add Card'),
            ),
            SizedBox(height: 20),
            if (_cardNumber != null && _expiryDate != null && _cardType != null)
              CardDetails(
                cardNumber: _cardNumber!,
                expiryDate: _expiryDate!,
                cardType: _cardType!,
              ),
          ],
        ),
      ),
    );
  }
}

class CardDetails extends StatelessWidget {
  final String cardNumber;
  final String expiryDate;
  final String cardType;

  CardDetails({
    required this.cardNumber,
    required this.expiryDate,
    required this.cardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Card Number: $cardNumber'),
        Text('Expiry Date: $expiryDate'),
        Text('Card Type: $cardType'),
      ],
    );
  }
}
