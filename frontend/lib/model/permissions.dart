class Permissions {
  Permissions({
    required this.permission,
    this.latitude,
    this.longitude,
    this.administrativeArea,
    this.street,
  });
  double? latitude;
  double? longitude;
  bool permission;
  String? administrativeArea;
  String? street;
}
