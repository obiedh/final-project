import 'package:geolocator/geolocator.dart';
import 'package:SportGrounds/providers/locationPermissionProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SportGrounds/screens/main_page.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(routes: [
  GoRoute(
    path: "/",
    builder: (context, state) => const ProviderScope(
      child: MainPageScreen(),
    ),
  ),
  GoRoute(
    path: "/news/:id/:path",
    name: "news",
    builder: (context, state) => const ProviderScope(
      child: MainPageScreen(),
    ),
    /*builder: (context, state) => NewsPage(
      userId: state.params["id"].toString(),
      path: state.params["path"].toString(),
    ),*/
  )
]);

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 131, 57, 0),
  ),
);

void main() {
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() {
    return _AppScreenState();
  }
}

class _AppScreenState extends ConsumerState<App> {
  var _isGettingLocation = false;

  Future<String?> _getCurrentLocation(WidgetRef ref) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ref
            .read(locationPermissionProvider.notifier)
            .addedPermission(false, 0.0, 0.0);
        throw Exception('Location services are disabled');
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            ref
                .read(locationPermissionProvider.notifier)
                .addedPermission(false, 0.0, 0.0);
            throw Exception('Location Permissions are denied');
          }
          ref
              .read(locationPermissionProvider.notifier)
              .addedPermission(false, 0.0, 0.0);
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ref
            .read(locationPermissionProvider.notifier)
            .addedPermission(false, 0.0, 0.0);
        throw Exception(
            'Location permissions are permanently denied, we cannot request');
      } else {
        setState(() {
          _isGettingLocation = true;
        });

        Position position = await Geolocator.getCurrentPosition();

        setState(() {
          _isGettingLocation = false;
        });

        // Process the obtained position here
        ref
            .read(locationPermissionProvider.notifier)
            .addedPermission(true, position.longitude, position.latitude);
      }
    } catch (e) {
      print('Error getting location: $e');
      // Handle the error appropriately
    }
    setState(() {
      _isGettingLocation = false;
    });
    return null;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(ref);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (_isGettingLocation) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return MaterialApp.router(
            title: 'FlutterChat',
            theme: theme,
            routerConfig: router,
          );
        }
      },
    );
  }
}
