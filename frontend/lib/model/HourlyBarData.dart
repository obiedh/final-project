class HourlyBarData {
  final Map<String, int> data;

  HourlyBarData({
    required this.data,
  });

  List<double> getHourlySummary() {
    return data.values.map((e) => e.toDouble()).toList();
  }

  List<String> getHours() {
    return data.keys.toList();
  }
}
