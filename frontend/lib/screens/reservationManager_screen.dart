import 'dart:convert';

import 'package:SportGrounds/screens/reservationDetailsManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:SportGrounds/model/constants.dart';
import 'package:SportGrounds/model/reservation.dart';
import 'package:SportGrounds/providers/usersProvider.dart';
import 'package:SportGrounds/screens/reservationDetails.dart';
import 'package:SportGrounds/screens/reservation_screen.dart';
import 'package:http/http.dart' as http;
import '../widgets/reservation_item.dart';

class ReservationScreenManager extends ConsumerStatefulWidget {
  const ReservationScreenManager({super.key});

  @override
  ConsumerState<ReservationScreenManager> createState() {
    // TODO: implement createState
    return _ReservationScreenManagerState();
  }
}

class _ReservationScreenManagerState
    extends ConsumerState<ReservationScreenManager> {
  bool _isLoading = false;
  List<Reservation> _myReservation = [];
  bool canCancel = false;

  @override
  void initState() {
    super.initState();
    _getReservations();
  }

  Future<void> _getReservations() async {
    final url = Uri.http(httpIP, 'api/get_reservations_by_manager');
    try {
      Map<String, dynamic> requestBody = {
        "manager_id": ref.read(userSingletonProvider).id,
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

      setState(() {
        _isLoading = false;
      });
      if (response.statusCode >= 400 || response.statusCode < 200) {
        print(response.body);
        //display error
      } else {
        final List<dynamic> listData = json.decode(response.body);
        for (final item in listData) {
          _myReservation.add(
            Reservation(
              status: item['status'],
              date: item['date'],
              stadiumId: item['field_id'],
              intervalTime: item['interval_time'],
              price: (item['price'] as int).toDouble(),
              imageURL: item['imageURL'],
              location: item['location'],
              name: item['name'],
              reservationUuid: item['uid'],
            ),
          );
        }
        print(_myReservation);
      }
    } catch (e) {
      print(e);
    }
  }

  String formatDateTimeToDateString(DateTime dateTime) {
    // Create a date format with the desired format (yyyy-MM-dd)
    final dateFormat = DateFormat('dd.M.yyyy');

    // Format the DateTime to a string with the specified format
    return dateFormat.format(dateTime);
  }

  List<Reservation> approvedReservations = [];
  List<Reservation> pendingReservations = [];
  List<Reservation> canceledReservations = [];
  void _sortReservations(List<Reservation> reservations) {
    approvedReservations = [];
    pendingReservations = [];
    canceledReservations = [];

    for (Reservation reservation in reservations) {
      switch (reservation.status) {
        case "Accepted":
          approvedReservations.add(reservation);
          break;
        case "pending":
          pendingReservations.add(reservation);
          break;
        case "canceled":
          canceledReservations.add(reservation);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _sortReservations(_myReservation);
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(255, 131, 57, 0),
        ),
      ),
      home: DefaultTabController(
        initialIndex: 1,
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(child: Text('Accepted')),
                Tab(child: Text('Pending')),
                Tab(child: Text('Canceled')),
              ],
            ),
            title: const Text('Reservations'),
          ),
          body: Stack(
            children: [
              TabBarView(
                children: [
                  ListView.builder(
                    itemCount: approvedReservations.length,
                    itemBuilder: (ctx, index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => ReservationScreen(
                                  reservation: approvedReservations[index],
                                ),
                              ),
                            );
                          });
                        },
                        child: ReservationItem(
                          reservation: approvedReservations[index],
                        ),
                      );
                    },
                  ),
                  ListView.builder(
                    itemCount: pendingReservations.length,
                    itemBuilder: (ctx, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => ReservationDetailsManagerScreen(
                                  reservation: pendingReservations[index]),
                            ),
                          );
                        },
                        child: ReservationItem(
                          reservation: pendingReservations[index],
                        ),
                      );
                    },
                  ),
                  ListView.builder(
                    itemCount: canceledReservations.length,
                    itemBuilder: (ctx, index) {
                      return InkWell(
                        onTap: () {
                          print("hey");
                        },
                        child: ReservationItem(
                          reservation: canceledReservations[index],
                        ),
                      );
                    },
                  ),
                ],
              ),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ))
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
