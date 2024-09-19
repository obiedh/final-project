import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:SportGrounds/model/constants.dart';
import 'package:SportGrounds/model/reservation.dart';
import 'package:SportGrounds/providers/confirmOrderProvider.dart';
import 'package:http/http.dart' as http;
import 'package:SportGrounds/providers/reservationCancelFlag.dart';

class ReservationDetailsManagerScreen extends ConsumerStatefulWidget {
  const ReservationDetailsManagerScreen({
    super.key,
    required this.reservation,
  });
  final Reservation reservation;

  @override
  ConsumerState<ReservationDetailsManagerScreen> createState() {
    return _ReservationDetailsManagerState();
  }
}

class _ReservationDetailsManagerState
    extends ConsumerState<ReservationDetailsManagerScreen> {
  bool _canCancel = false;
  bool _isLoading = false;
  String _reservationStatus = "";
  @override
  void initState() {
    super.initState();
    _canCancel = _canCancelDate(widget.reservation.intervalTime,
        widget.reservation.date, formatDateTimeToDateString(DateTime.now()));
  }

  String formatDateTimeToDateString(DateTime dateTime) {
    // Create a date format with the desired format (yyyy-MM-dd)
    final dateFormat = DateFormat('dd.M.yyyy');

    // Format the DateTime to a string with the specified format
    return dateFormat.format(dateTime);
  }

  bool _canCancelDate(String intervalTime, String date, String currentDate) {
    // Define the date and time format
    final dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');

    // Parse the date and current date strings
    final parsedDate =
        dateTimeFormat.parse("$date $intervalTime.split('-')[0]");
    final parsedCurrentDate = dateTimeFormat
        .parse("$currentDate ${DateFormat('HH:mm').format(DateTime.now())}");

    // Calculate the difference in hours
    final hoursDifference = parsedDate.difference(parsedCurrentDate).inHours;
    print(hoursDifference);
    // Check if the difference is more than 6 hours
    return hoursDifference > 6;
  }

  Future<void> _updateReservationStatus(String status) async {
    final url = Uri.http(httpIP, 'api/update_reservation_status');

    try {
      Map<String, dynamic> requestBody = {
        "reservation_uuid": widget.reservation.reservationUuid,
        "status": status,
      };

      final response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode >= 400) {
      } else {
        print("updated");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  void showPopUpMessage(BuildContext context, String message, String title,
      String reservationStatus) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Perform the  action associated with OK here
                // Close the dialog
                setState(() {
                  _isLoading = true;
                });
                await _updateReservationStatus(reservationStatus);
                setState(() {
                  ref.read(flagProvider.notifier).turFlagON(true);
                  _isLoading = false;
                });
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                // Perform the action associated with Cancel here
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(_canCancel);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Details '),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.reservation.name,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                Image.asset(
                  widget.reservation.imageURL,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.fitWidth,
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    const SizedBox(
                      width: 38,
                    ),
                    const Icon(Icons.date_range),
                    Text(widget.reservation.date),
                    const SizedBox(
                      width: 20,
                    ),
                    const Icon(Icons.timer),
                    Text(
                      widget.reservation.intervalTime,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    const Icon(Icons.location_on_outlined),
                    Text(widget.reservation.location),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Price',
                  style: TextStyle(fontSize: 40),
                ),
                Text(
                  (widget.reservation.price).toString(),
                  style: const TextStyle(fontSize: 30),
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outlined),
                    Text(
                      'Customer details',
                      style: TextStyle(fontSize: 15),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person),
                    Text('Ebrahem Enbtawe'),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_android),
                    Text('0546333949'),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        showPopUpMessage(
                            context,
                            "Are you sure you want to Decline the customer's reservation?",
                            "Decline Reservation",
                            "canceled");
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 60,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(
                      width: 230,
                    ),
                    IconButton(
                      onPressed: () {
                        showPopUpMessage(
                            context,
                            "Are you sure you want to Accept the customer's reservation?",
                            "Accept Reservation",
                            "Accepted");
                      },
                      icon: const Icon(
                        Icons.check,
                        size: 60,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
