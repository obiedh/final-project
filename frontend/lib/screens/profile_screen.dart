import 'package:flutter/material.dart';
import 'package:SportGrounds/providers/usersProvider.dart';
import 'package:SportGrounds/screens/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("building profilescreen");
    String authenticationVar =
        ref.watch(userSingletonProvider).authenticationVar;
    String name = ref.read(userSingletonProvider).name;
    var usersProvider = ref.read(userSingletonProvider);
    if (authenticationVar == "") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                  "you are not signed in,\n please Sign in to see your profile"),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => const AuthScreen(),
                    ));
                  },
                  child: const Text("Sign in")),
            ],
          ),
        ],
      );
      //Navigator.of(context).push(MaterialPageRoute(
      //builder: (ctx) => AuthScreen(),));
    }
    List<Widget> admincontent = [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Section :',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
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
              child: const Text('Current Requests'),
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
              child: const Text('Pricing'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 15),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary),
              ),
              onPressed: () {
                // Handle 'All Requests' button tap.
              },
              child: const Text('All Requests'),
            ),
          ),
        ],
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/user_profile.jpg'),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Birthdate:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'January 1, 1990',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                'Phone Number:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                usersProvider.phoneNumber,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (name == "admin") ...admincontent
      ],
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("hello ${ref.read(userSingletonProvider).name}"),
          ],
        ),
      ],
    );
  }
}
