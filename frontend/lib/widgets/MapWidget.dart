/*import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:SportGrounds/model/stadium.dart';
import 'package:SportGrounds/providers/locationPermissionProvider.dart';

class MapScreen extends ConsumerStatefulWidget {
  MapScreen(
      {super.key,
      required this.filteredStadiums,
      required this.onprocessIntervalsAndReservations,
      required this.onselectStadium});
  List<Stadium> filteredStadiums;
  final Future<void> Function(Stadium stadium)
      onprocessIntervalsAndReservations;
  final void Function(BuildContext context, Stadium stadium) onselectStadium;
  @override
  ConsumerState<MapScreen> createState() {
    return _MapScreenState();
  }
}

class _MapScreenState extends ConsumerState<MapScreen> {
  String texter = "";
  Stadium? tappedStadium;
  List<Marker> markerslist = [];

  @override
  Widget build(BuildContext context) {
    List<Marker> markerslist = [
      Marker(
        width: 50.0,
        height: 50.0,
        point: LatLng(
            ref.read(locationPermissionProvider).latitude!,
            ref
                .read(locationPermissionProvider)
                .longitude!), // Coordinates of the marker
        builder: (ctx) => GestureDetector(
          onTap: () {
            setState(() {
              texter = "pressed my location";
            });
          },
          child: Container(
            child: const Column(
              children: [
                Text("You",
                    style: TextStyle(
                        color: Colors.white,
                        decorationStyle: TextDecorationStyle.solid,
                        backgroundColor: Color.fromARGB(85, 0, 0, 0))),
                Icon(
                  Icons.person_pin,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    ];
    print("before for");
    print(widget.filteredStadiums);
    for (final stadium in widget.filteredStadiums) {
      //print("stadium : ${stadium.latitude}  and  ${stadium.longitude}");
      markerslist.add(
        Marker(
          width: 30.0,
          height: 30.0,
          point: LatLng(
              stadium.latitude, stadium.longitude), // Coordinates of the marker
          builder: (ctx) => GestureDetector(
            onTap: () {
              setState(() {
                tappedStadium = stadium;
              });
            },
            child: Container(
              child: const Icon(
                Icons.location_pin,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );
    }
    print("after for");

    return Column(
      children: [
        Expanded(
          flex: 8,
          child: FlutterMap(
            options: MapOptions(
              center: LatLng(32.813, 35.172), // Default map location
              zoom: 12.0, // Initial zoom level
            ),
            layers: [
              TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayerOptions(
                markers: markerslist,
              ),
            ],
          ),
        ),
        tappedStadium != null
            ? Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(tappedStadium!.imagePath),
                      Column(
                        children: [
                          Text(tappedStadium!.title!,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  //_isLoading = true;
                                });
                                await widget.onprocessIntervalsAndReservations(
                                    tappedStadium!);
                                setState(() {
                                  //_isLoading = false;
                                });

                                widget.onselectStadium(context, tappedStadium!);
                              },
                              child: const Text("Reserve")),
                        ],
                      )
                    ],
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}*/
