import 'dart:convert';

import 'package:SportGrounds/model/constants.dart';
import 'package:SportGrounds/providers/fieldsProvider.dart';
import 'package:SportGrounds/providers/usersProvider.dart';
import 'package:SportGrounds/screens/editFieldScreen.dart';
import 'package:flutter/material.dart';
import 'package:SportGrounds/model/stadium.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:http/http.dart' as http;

import 'package:http/http.dart' as http;

class StadiumItemManager extends ConsumerStatefulWidget {
  const StadiumItemManager({
    super.key,
    required this.stadium,
    required this.onSelectStadium,
  });
  final Stadium stadium;
  final void Function(Stadium stadium) onSelectStadium;

  ConsumerState<StadiumItemManager> createState() {
    return _StadiumItemManager();
  }
}

class _StadiumItemManager extends ConsumerState<StadiumItemManager> {
  bool _isLoading = false;
  Future<Widget> loadImageFromUrl(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final imageBytes = response.bodyBytes;
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover, // You can adjust the fit as needed
      );
    } else {
      // Handle error, e.g., by displaying a placeholder image
      return Image.asset('assets/placeholder.png');
    }
  }

  double extractDigitAndOneDecimal(double value) {
    // Convert the double to a string
    String stringValue = value.toString();

    // Find the index of the decimal point
    int dotIndex = stringValue.indexOf('.');

    if (dotIndex == -1 || dotIndex == stringValue.length - 1) {
      return 0.0; // No decimal point or no digits after the decimal point
    }

    // Extract the digit and one decimal place after the decimal point
    String extractedValue = stringValue.substring(0, dotIndex + 2);

    // Parse the result to a double
    return double.parse(extractedValue);
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this field?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Okay'),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                await _deleteField();
                setState(() {
                  _isLoading = false;
                });
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _deleteField() async {
    final url = Uri.http(httpIP, 'api/delete_field');
    try {
      Map<String, dynamic> requestBody = {
        "field_id": widget.stadium.id,
        "manager_id": ref.read(userSingletonProvider).id
      };

      final response = await http.delete(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        print(response.body);
        return false;
      } else {
        ref.read(stadiumListProvider.notifier).removeStadium(widget.stadium.id);
      }
    } catch (error) {
      print("error");
      print("Error: $error");
      setState(() {
        // Handle the error
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.hardEdge, //to force the rounded shape
      elevation: 2,
      child: InkWell(
        onTap: () {
          widget.onSelectStadium(widget.stadium);
        },
        child: Stack(
          children: [
            FadeInImage(
              placeholder: MemoryImage(kTransparentImage),
              image: AssetImage(widget.stadium.imagePath),
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: const Color.fromARGB(120, 0, 0, 0),
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 40),
                child: Column(
                  children: [
                    Text(
                      widget.stadium.title!,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      overflow: TextOverflow.fade, //how the text is cut off
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Add your logic here
                          },
                          child: Image.asset(
                            'lib/images/edit.jpg',
                            width: 40, // Set the width of the image
                            height: 60, // Set the height of the image
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => EditFieldScreen(
                                  stadium: widget.stadium,
                                ),
                              ),
                            );
                          },
                          child: Text('Edit'),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        const SizedBox(
                          width: 50,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showConfirmationDialog(context);
                          },
                          child: Text('Delete'),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Image.asset(
                            'lib/images/delete.png',
                            width: 40, // Set the width of the image
                            height: 50, // Set the height of the image
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
