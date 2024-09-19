import 'package:flutter/material.dart';
import 'package:SportGrounds/model/stadium.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:SportGrounds/widgets/stadium_item_trait.dart';
import 'package:http/http.dart' as http;

class StadiumItem extends StatefulWidget {
  const StadiumItem({
    super.key,
    required this.stadium,
    required this.onSelectStadium,
  });
  final Stadium stadium;
  final void Function(Stadium stadium) onSelectStadium;

  @override
  State<StadiumItem> createState() => _StadiumItem();
}

class _StadiumItem extends State<StadiumItem> {
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
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 44),
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
                        StadiumItemTrait(
                          icon: widget.stadium.distance == 0.0
                              ? Icons.location_disabled_outlined
                              : Icons.directions_car,
                          label: widget.stadium.distance == 0.0
                              ? 'N/A'
                              : '${extractDigitAndOneDecimal(widget.stadium.distance!)}km',
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        StadiumItemTrait(
                          icon: Icons.star_outline_outlined,
                          label: widget.stadium.rating.toString(),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        StadiumItemTrait(
                          icon: Icons.location_on,
                          label: widget.stadium.location,
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
