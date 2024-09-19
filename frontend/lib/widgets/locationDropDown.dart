import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SportGrounds/providers/filtersProvider.dart';

class DropdownLocationButton extends ConsumerStatefulWidget {
  final List<String> locations;

  const DropdownLocationButton({super.key, required this.locations});

  @override
  ConsumerState<DropdownLocationButton> createState() {
    return _DropdownButtonExampleState();
  }
}

class _DropdownButtonExampleState
    extends ConsumerState<DropdownLocationButton> {
  String dropdownValue = "All";

  @override
  Widget build(BuildContext context) {
    ref.watch(filterSingletonProvider).isFilterOn;
    List<String> locationList =
        widget.locations.isNotEmpty ? ["All", ...widget.locations] : ["All"];

    return DropdownButton<String>(
      value: ref.read(filterSingletonProvider).isFilterOn == false
          ? "All"
          : ref.read(filterSingletonProvider).location,
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
          ref
              .read(filterSingletonProvider.notifier)
              .appliedLocationFilter(dropdownValue);
        });
      },
      items: locationList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 12, color: Color.fromARGB(255, 255, 197, 158)),
          ),
        );
      }).toList(),
      underline: Container(),
    );
  }
}
