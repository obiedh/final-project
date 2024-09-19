import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SportGrounds/model/constants.dart';
import 'package:SportGrounds/model/creditCard.dart';
import 'package:SportGrounds/providers/creditCardProvider.dart';
import 'package:SportGrounds/screens/creditCardForm.dart';
import 'package:http/http.dart' as http;
import 'package:SportGrounds/screens/reservationsScreen.dart';

import '../providers/usersProvider.dart';

class CreditCardScreen extends ConsumerStatefulWidget {
  const CreditCardScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MainPageScreenState();
  }
}

class _MainPageScreenState extends ConsumerState<CreditCardScreen> {
  bool _isLoading = false;
  bool _paymentExist = false;
  CreditCard creditCard = CreditCard(
    name: "",
    cardNumber: "",
  );

  @override
  void initState() {
    super.initState();
    _getPayment();
  }

  Future<bool?> _getPayment() async {
    print("HERE");
    print(ref.read(userSingletonProvider).id);
    final url = Uri.http(httpIP, 'api/get_payment_by_id');
    try {
      Map<String, dynamic> requestBody = {
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

      if (response.statusCode >= 400 || response.statusCode < 200) {
        _paymentExist = false;
        print(response.body);
        ref.read(creditCardProvider.notifier).deleteCreditCard();
        setState(() {
          _isLoading = false;
        });
        return false;
      } else {
        setState(() {
          _paymentExist = true;
          final List<dynamic> listData = json.decode(response.body);
// Assuming each item in the listData is a Map<String, dynamic>
          final List<CreditCard> loadedItems = listData.map((item) {
            creditCard.cardNumber = item['cardNumber'];
            creditCard.name = item['name'];
            return creditCard;
          }).toList();

          ref.read(creditCardProvider.notifier).addCreditCard(creditCard);

          setState(() {
            _isLoading = false;
          });
          _isLoading = false;
        });
      }
    } catch (error) {
      print("error");
      print("Error: $error");
      setState(() {
        ref.read(creditCardProvider.notifier).deleteCreditCard();
        _paymentExist = false;
        _isLoading = false;
      });
    }

    return true;
  }

  /*final response = await http.delete(
    Uri.parse('https://example.com/api/endpoint'), // Replace with your API endpoint
    headers: <String, String>{
      'Content-Type': 'application/json', // Adjust headers as needed
    },
  );

  if (response.statusCode == 200) {
    print('DELETE request successful');
  } else {
    print('DELETE request failed with status: ${response.statusCode}');
  }
}*/

  Future<bool?> deletePayment() async {
    final url = Uri.http(httpIP, 'api/delete_payment');
    final response;

    try {
      Map<String, dynamic> requestBody = {
        "user_id": ref.read(userSingletonProvider).id,
        "cardNumber": ref.read(creditCardProvider).cardNumber,
      };
      setState(() {
        _isLoading = true;
      });
      final response = await http.delete(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      if (response.statusCode >= 400 || response.statusCode < 200) {
        _paymentExist = false;
        ref.read(creditCardProvider.notifier).deleteCreditCard();
        setState(() {
          _isLoading = false;
        });
        return false;
      } else {
        setState(() {
          _paymentExist = true;
        });
      }
    } catch (error) {
      print("error");
      print("Error: $error");
      setState(() {
        ref.read(creditCardProvider.notifier).deleteCreditCard();
        _paymentExist = false;
        _isLoading = false;
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    print("BUILD ETHOD");
    ref.watch(creditCardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment method'),
      ),
      body: ref.read(creditCardProvider).cardNumber != ""
          ? Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    top: 300,
                    bottom: 80,
                    left: 20,
                    right: 40,
                  ),
                  width: 500,
                  child: Image.asset('lib/images/creditCard.jpg'),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              'Hey ${ref.read(creditCardProvider).name} here is your current Payment Method ',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Dismissible(
                          key: const Key('itemKey'),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Deletion'),
                                  content: const Text(
                                      'Are you sure you want to delete this item?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          deletePayment();
                                          Navigator.of(context).pop(true);
                                        });
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              ref
                                  .read(creditCardProvider.notifier)
                                  .deleteCreditCard();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Item dismissed'),
                                ),
                              );
                            }
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              print(":ffff");
                              // Handle click on the card
                            },
                            child: Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(20.0),
                                title: Row(
                                  children: [
                                    const Icon(
                                      Icons.credit_card,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(maskCreditCardNumber(ref
                                        .read(creditCardProvider)
                                        .cardNumber)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.tips_and_updates),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Text(
                              'If you want to add another Credit Card, please make sure to delete the current one',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.tips_and_updates),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Text(
                              'Please swipe left on your card to remove it',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 200),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No Payment method found! ',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => const CreditCardForm(),
                            ),
                          );
                        },
                        child: const Text('Add Payment Method!'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  String maskCreditCardNumber(String cardNumber) {
    String maskedNumber = '';
    for (int i = 0; i < 12; i++) {
      maskedNumber += '*';
      if ((i + 1) % 4 == 0) {
        maskedNumber += ' ';
      }
    }
    maskedNumber += cardNumber.substring(12); // Append the last 4 characters
    return maskedNumber;
  }
}
