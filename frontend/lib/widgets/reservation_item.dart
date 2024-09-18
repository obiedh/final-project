import 'package:flutter/material.dart';
import 'package:SportGrounds/model/reservation.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:SportGrounds/widgets/stadium_item_trait.dart';

import '../model/enumStatus.dart';

class ReservationItem extends StatelessWidget {
  const ReservationItem({super.key, required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.hardEdge, //to force the rounded shape
      elevation: 2,
      child: Stack(
        children: [
          FadeInImage(
            placeholder: MemoryImage(kTransparentImage),
            image: AssetImage(reservation.imageURL),
            fit: BoxFit.cover,
            height: 360,
            width: double.infinity,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: const Color.fromARGB(120, 0, 0, 0),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 44),
              child: Column(
                children: [
                  const Text(
                    "Reservation Details",
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis, //how the text is cut off
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('(Click to see more)')],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      StadiumItemTrait(
                        icon: Icons.date_range,
                        label: reservation
                            .date, //'${DateFormat('yyyy/MM/dd HH:mm').format(reservation.date)}m',
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      StadiumItemTrait(
                        icon: Icons.timer,
                        label: reservation.intervalTime,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      StadiumItemTrait(
                          icon: reservation.status == "pending"
                              ? Icons.pending
                              : reservation.status == "canceled"
                                  ? Icons.close
                                  : Icons.check,
                          label: reservation.status == "Accepted"
                              ? "Approved"
                              : reservation.status == "pending"
                                  ? "Pending"
                                  : reservation.status == "canceled"
                                      ? "Canceled"
                                      : ""),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
