class Stadium {
  const Stadium({
    required this.id,
    required this.title,
    required this.location,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.rating,
    this.utilities,
    this.distance, // Distance is optional
    this.availability,
  });

  final String? availability;
  final String? utilities;
  final String id;
  final String title;
  final String location;
  final String imagePath;
  final double longitude;
  final double latitude;
  final double? distance; // Distance is nullable (optional)
  final String type;
  final String? rating;

  Stadium copyWith({
    String? utilities,
    String? title,
    String? availability,
  }) {
    return Stadium(
      id: id,
      title: title ?? this.title,
      location: location,
      imagePath: imagePath,
      latitude: latitude,
      longitude: longitude,
      type: type,
      rating: rating,
      utilities: utilities ?? this.utilities,
      distance: distance,
      availability: availability ?? this.availability,
    );
  }

  @override
  String toString() {
    return 'Stadium{id: $id, title: $title, location: $location, imagePath: $imagePath, latitude: $latitude, longitude: $longitude, type: $type, rating: $rating, utilities: $utilities, distance: $distance, availability: $availability}';
  }
}
