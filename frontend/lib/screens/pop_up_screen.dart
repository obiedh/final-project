




import 'package:flutter/material.dart';

class PopupScreen extends StatelessWidget {
  const PopupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popup Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Popup Text'),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(labelText: 'Enter Text'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add functionality for the button in the popup screen
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}