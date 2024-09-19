import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:SportGrounds/providers/creditCardProvider.dart';
import 'package:SportGrounds/providers/usersProvider.dart';

import '../model/constants.dart';
import '../model/creditCard.dart';

class CreditCardForm extends ConsumerStatefulWidget {
  const CreditCardForm({super.key});

  @override
  ConsumerState<CreditCardForm> createState() {
    return _CreditCardFormState();
  }
}

class _CreditCardFormState extends ConsumerState<CreditCardForm> {
  final _formKey = GlobalKey<FormState>();
  bool isValid = false;
  bool _isLoading = false;
  String cardHoldername = "";
  String cardNumber = "";
  String month = "";
  String year = "";
  String id = "";
  String digitCode = "";
  bool paymentCreateSuccess = false;

  bool containsLettersOnly(String input) {
    RegExp digitRegExp = RegExp(r'\d'); // Regular expression to match digits

    if (digitRegExp.hasMatch(input)) {
      return false;
    }

    return true;
  }

  void showPaymentMethodConfirmationPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Your payment Method is created!'),
          content: const Text('Congratulations, you can now book stadiums!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
                Navigator.of(context).pop();

                // Perform redirection or other actions here
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _createPayment() async {
    isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return false;
    }
    _formKey.currentState!.save();
    final url = Uri.http(httpIP, 'api/create_payment');
    try {
      Map<String, dynamic> requestBody = {
        "carHolderID": id,
        "cardNumber": cardNumber,
        "digitCode": digitCode,
        "month": month,
        "name": cardHoldername,
        "year": year,
        "userid": ref.read(userSingletonProvider).id,
      };

      setState(() {
        _isLoading = true;
      });
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode >= 400) {
        setState(() {
          _isLoading = false;
        });
        return false;
      } else {
        print(response.body);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print("error");
      print("Error: $error");
      setState(() {
        // Handle the error
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment Method'),
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(
              top: 560,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            width: 500,
            child: Image.asset('lib/images/paymentMehod.jpg'),
          ),
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    onChanged: (value) {
                      cardHoldername = value;
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(16),
                    ],
                    maxLength: 30,
                    decoration: const InputDecoration(
                      label: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'Card Holder Name',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Card Holder Name!';
                      } else {
                        if (!containsLettersOnly(value)) {
                          return 'Please Enter a Valid Card Holder Name! Cannot contain Digits. ';
                        }
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      cardNumber = value;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                    ],
                    maxLength: 16,
                    decoration: const InputDecoration(
                      label: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'Card Number',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Card Number';
                      } else {
                        if (value.length < 16) {
                          return 'Card Number must be 16 digits';
                        }
                        return null;
                      }
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField(
                          validator: (value) {
                            if (value == null) {
                              return 'Please select Month';
                            } else {
                              return null;
                            }
                          },
                          items: List.generate(12, (index) {
                            return DropdownMenuItem(
                              value: index + 1,
                              child: Text('${index + 1}'),
                            );
                          }),
                          onChanged: (value) {
                            month = value.toString();
                          },
                          decoration: const InputDecoration(
                            labelText: 'Select Month:',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),

                      Expanded(
                        child: DropdownButtonFormField(
                          validator: (value) {
                            if (value == null) {
                              return 'Please Select Year';
                            } else {
                              return null;
                            }
                          },
                          items: List.generate(18, (index) {
                            return DropdownMenuItem(
                              value: 2023 + index,
                              child: Text('${2023 + index}'),
                            );
                          }),
                          onChanged: (value) {
                            year = value.toString();
                          },
                          decoration: const InputDecoration(
                            labelText: 'Select Year:',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      //DropdownButtonFormField(items: items, onChanged: () {}),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      id = value;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    maxLength: 9,
                    decoration: const InputDecoration(
                      label: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'ID Number',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter ID';
                      } else {
                        if (value.length < 9) {
                          return 'ID must be 9 digits';
                        }
                        return null;
                      }
                    },
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    onChanged: (value) {
                      digitCode = value;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    maxLength: 3,
                    decoration: const InputDecoration(
                      label: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          '3-Digit Code',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Code';
                      } else {
                        if (value.length < 3) {
                          return 'Please enter valid Digit code (3 digits on the back of the card)';
                        }
                        return null;
                      }
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        if (_formKey.currentState!.validate()) {
                          paymentCreateSuccess = await _createPayment();
                          ref.read(creditCardProvider.notifier).addCreditCard(
                              CreditCard(
                                  cardNumber: cardNumber,
                                  name: cardHoldername));

                          setState(() {
                            _isLoading = false;
                          });
                          ref.read(creditCardProvider.notifier).addCreditCard(
                              CreditCard(
                                  cardNumber: cardNumber,
                                  name: cardHoldername));
                          showPaymentMethodConfirmationPopup(context);
                        }
                        setState(() {
                          _isLoading = false;
                        });
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ))
              : const SizedBox(),
        ],
      ),
    );
  }
}
