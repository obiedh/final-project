import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/model/permissions.dart';

Permissions permission = Permissions(permission: false);

class LocationSingletonNotifier extends StateNotifier<Permissions> {
  LocationSingletonNotifier() : super(permission);

  void addedPermission(bool permission, double longitude, double latitude) {
    state = Permissions(
      permission: permission,
      longitude: longitude,
      latitude: latitude,
    );
  }

  void addedCurrentLocation(
      bool permission, String street, String administrativeArea) {
    state = Permissions(
      permission: state.permission,
      street: street,
      administrativeArea: administrativeArea,
    );
  }
}

final locationPermissionProvider =
    StateNotifierProvider<LocationSingletonNotifier, Permissions>(
  (ref) => LocationSingletonNotifier(),
);
