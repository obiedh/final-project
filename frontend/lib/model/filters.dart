class Filters {
  Filters({
    required this.date,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.availableTime,
    required this.dateForInit,
    this.isFilterOn,
  });
  final String date;
  final String location;
  final String startTime;
  final String endTime;
  List<Map<String, String>> availableTime; // Change here
  final DateTime dateForInit;
  bool? isFilterOn;
  //going to add location
}
