import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SportGrounds/model/reservation.dart';

class ReservationScreen extends ConsumerStatefulWidget {
  ReservationScreen({super.key, required this.reservation});
  Reservation reservation;

  @override
  ConsumerState<ReservationScreen> createState() {
    // TODO: implement createState
    return _ReservationScreenState();
  }
}

class _ReservationScreenState extends ConsumerState<ReservationScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("reservation at stadium ${widget.reservation.stadiumId}"),
      ),
      body: SingleChildScrollView(
        child: Column(
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
            DataTable(
              columns: const <DataColumn>[
                DataColumn(
                  label: Text('ID'),
                ),
                DataColumn(
                  label: Text('Name'),
                ),
              ],
              rows: List<DataRow>.generate(
                15,
                (int index) => DataRow(
                  cells: <DataCell>[
                    DataCell(Text('${index + 1}')),
                    DataCell(Text('Name ${index + 1}')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
