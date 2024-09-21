import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SportGrounds/providers/confirmOrderProvider.dart';
import 'package:http/http.dart' as http;
import 'package:SportGrounds/screens/creditCardForm.dart';
import '../model/constants.dart';
import '../model/creditCard.dart';
import '../model/stadium.dart';
import '../providers/creditCardProvider.dart';
import '../providers/usersProvider.dart';
import 'creditCard.dart';

class ConfirmBookScreen extends ConsumerStatefulWidget {
  const ConfirmBookScreen({super.key, required this.stadium});
  final Stadium stadium;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ConfirmBookState();
  }
}

class _ConfirmBookState extends ConsumerState<ConfirmBookScreen> {
  bool _isLoading = false;
  bool _paymentExist = false;
  CreditCard creditCard = CreditCard(
    name: "",
    cardNumber: "",
  );

  Future<void> _createReservation(WidgetRef ref) async {
    final url = Uri.http(httpIP, 'api/create_reservation');

    // Use the helper function to format the date
    String formattedDate = formatDate(ref.read(confirmOrderProvider).date);

    try {
      Map<String, dynamic> requestBody = {
        "field_id": widget.stadium.id,
        "date": formattedDate,
        "interval_time": ref.read(confirmOrderProvider).intervalTime,
        "status": "pending",
        "du_date": "28.6.2023",
        "du_time": "18:00",
        "user_uuid": ref.read(userSingletonProvider).id,
        "field_name": widget.stadium.title,
        "location": widget.stadium.location,
        "imageURL": widget.stadium.imagePath,
        "price": ref
            .read(confirmOrderProvider)
            .price, //need to put the price from the db
      };

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode >= 400) {
      } else {}
    } catch (error) {
      print("Error: $error");
    }
  }

  @override
  void initState() {
    super.initState();
    _getPayment();
  }

  String maskCreditCardNumber(String cardNumber) {
    String maskedNumber = '';
    for (int i = 0; i < 12; i++) {
      maskedNumber += '* ';
      if ((i + 1) % 4 == 0) {
        maskedNumber += ' ';
      }
    }
    maskedNumber += cardNumber.substring(12); // Append the last 4 characters
    return maskedNumber;
  }

  String formatDate(String date) {
    // Assuming the date format is "dd.MM.yyyy"
    List<String> parts = date.split('.');

    // Extract day, month, and year from the date
    String day = parts[0];
    String month = parts[1].length < 2
        ? '0${parts[1]}'
        : parts[1]; // Add leading zero if month is < 10
    String year = parts[2];

    // Return the formatted date
    return '$day.$month.$year';
  }

  Future<bool?> _getPayment() async {
    final url = Uri.http(httpIP, 'api/get_payment_by_id');
    try {
      Map<String, dynamic> requestBody = {
        "userid": ref.read(userSingletonProvider).id,
      };
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

  void _showReservationConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reservation Successful'),
          content: const Text('Your reservation has been created successfully. '
              'You can review your reservation in your HomePage under "My Games" Tab.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Reservation'),
          content: const Text('Are you sure you want to book this stadium?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                await _createReservation(ref);
                _showReservationConfirmationDialog(context);
                setState(() {
                  _isLoading = false;
                });
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(creditCardProvider);
    print("activate buiold");
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(
        backgroundColor: Colors.white,
      ));
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Confirm Booking'),
        ),
        body: Stack(children: [
          Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color.fromARGB(255, 255, 197, 158),
                  ),
                  Text(widget.stadium.location),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    color: Color.fromARGB(255, 255, 197, 158),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text('Date and time of Booking'),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ref.read(confirmOrderProvider).date,
                  ),
                  const Text(' , '),
                  Text(ref.read(confirmOrderProvider).intervalTime),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.payment_outlined,
                    color: Color.fromARGB(255, 255, 197, 158),
                  ),
                  SizedBox(
                    width: 10,
                    height: 100,
                  ),
                  Text(
                    'Pyment Method',
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const CreditCardScreen(),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(20.0),
                          title: ref.read(creditCardProvider).cardNumber != ""
                              ? Row(
                                  children: [
                                    const Icon(
                                      Icons.credit_card,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(maskCreditCardNumber(ref
                                        .read(creditCardProvider)
                                        .cardNumber)),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    const Icon(Icons.check_box),
                                  ],
                                )
                              : Row(
                                  children: [
                                    const Icon(
                                      Icons.credit_card,
                                    ),
                                    const SizedBox(width: 240),
                                    ElevatedButton(
                                        onPressed: () async {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (ctx) =>
                                                  const CreditCardForm(),
                                            ),
                                          );
                                        },
                                        child: _isLoading
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                backgroundColor: Colors.white,
                                              ))
                                            : const Text('Add'))
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ref.read(confirmOrderProvider).price.toString(),
                    style: const TextStyle(
                        color: Color.fromARGB(255, 255, 197, 158),
                        fontSize: 50),
                  )
                ],
              ),
              const Divider(),
              const SizedBox(
                height: 100,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (ref.read(creditCardProvider).cardNumber == "") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please add a Payment Method to place your reservation!!'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      } else {
                        _showConfirmationDialog(context, ref);
                      }
                    },
                    child: const Text(
                      'Confirm',
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                ],
              )
            ],
          ),
        ]),
      );
    }
  }
}
