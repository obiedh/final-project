import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SportGrounds/providers/confirmOrderProvider.dart';
import 'package:SportGrounds/screens/confirmReservation.dart';

import '../model/stadium.dart';
import '../providers/usersProvider.dart';
import '../screens/auth.dart';

class AvailabilityWidget extends ConsumerStatefulWidget {
  const AvailabilityWidget(
      {super.key,
      required this.remainingInterval,
      required this.stadium,
      required this.date});

  final List<Map<String, String>> remainingInterval;
  final Stadium stadium;
  final String date;

  @override
  ConsumerState<AvailabilityWidget> createState() {
    return _AvailabilityWidgetState();
  }
}

class _AvailabilityWidgetState extends ConsumerState<AvailabilityWidget> {
  bool isExpanded = false;

  void _showSignInDialog(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign In Required'),
          content: const Text('You must sign in to proceed.'),
          actions: [
            TextButton(
              onPressed: () async {
                String authvar = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const AuthScreen(),
                  ),
                );
                if (authvar != "") {
                  Navigator.pop(context);
                }
                if (ref.read(userSingletonProvider).authenticationVar ==
                    "manager") {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              },
              child: const Text('Sign In'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(userSingletonProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('Availability'),
          trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
          onTap: () {
            toggleExpanded();
          },
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: ListView(
              shrinkWrap: true,
              children: widget.remainingInterval.map((item) {
                return InkWell(
                  onTap: () {
                    if (ref.read(userSingletonProvider).authenticationVar ==
                        "") {
                      _showSignInDialog(context, ref);
                    } else {
                      ref
                          .read(confirmOrderProvider.notifier)
                          .addTimeInterval(item['time']!, item['price']!);
                      ref
                          .read(confirmOrderProvider.notifier)
                          .addDate(widget.date);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) =>
                              ConfirmBookScreen(stadium: widget.stadium),
                        ),
                      );
                    }
                    print('${item['time']} clicked');
                  },
                  child: ListTile(
                    title: Text(item['time']!),
                    subtitle: Text('Price: \$${item['price']}'),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
