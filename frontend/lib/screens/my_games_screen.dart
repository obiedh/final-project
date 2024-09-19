import 'package:flutter/material.dart';
import 'package:SportGrounds/model/reservation.dart';
import 'package:SportGrounds/screens/reservation_screen.dart';
import 'package:SportGrounds/widgets/reservation_item.dart';
import 'dart:core';

final MyReservations = [
  Reservation(
    imageURL: "",
    location: "",
    name: "",
    status: "approved",
    reservationId: "3",
    stadiumId: "2",
    date: DateTime.now().toString(),
    intervalTime: "16:00-18:00",
    price: 30,
    reservationUuid: "4564564564",
  ),
  Reservation(
    imageURL: "",
    location: "",
    name: " ",
    status: "approved",
    reservationId: "3",
    stadiumId: "2",
    date: DateTime.now().toString(),
    intervalTime: "16:00-18:00",
    price: 30,
    reservationUuid: "4564564564",
  ),
];

class MyGamesScreen extends StatefulWidget {
  const MyGamesScreen({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _MyGamesScreenState();
  }
}

class _MyGamesScreenState extends State<MyGamesScreen> {
  @override
  Widget build(BuildContext context) {
    print("building my games");
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.onPrimary),
                ),
                onPressed: () {
                  // Handle 'Current Requests' button tap.
                },
                child: const Text('Add Reservation +'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.onPrimary),
                ),
                onPressed: () {
                  // Handle 'Pricing' button tap.
                },
                child: const Text('Select'),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: ListView.builder(
              itemCount: MyReservations.length,
              itemBuilder: (ctx, index) {
                return InkWell(
                  onTap: () {
                    print("hey");
                    setState(() {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => ReservationScreen(
                            reservation: MyReservations[index],
                          ),
                        ),
                      );
                    });
                  },
                  child: ReservationItem(
                    reservation: MyReservations[index],
                  ),
                );
              }),
        ),
      ],
    );
  }
}
