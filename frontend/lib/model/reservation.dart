
class Reservation {
  Reservation({
    this.reservationUuid,
    required this.status,
    required this.date,
    required this.stadiumId,
    this.reservationId,
    required this.intervalTime,
    required this.price,
    required this.location,
    required this.imageURL,
    required this.name,
    


  });
  final String name; 
  final String location;
  final String imageURL;
  final String? reservationUuid;
  late String status;
  final String date;
  final String stadiumId;
  final String? reservationId;
  final String intervalTime;
  final double price;

  @override
  String toString() {
    return 'Reservation: {approved: $status,reservationId: $reservationId, stadiumId: $stadiumId, date: $date, intervalTime: $intervalTime}';
  }
}
