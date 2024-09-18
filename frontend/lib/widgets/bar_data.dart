import 'package:flutter/material.dart';

class BarData {
  final String field;
  final Map<int, int> data;

  BarData({
    required this.field,
    required this.data,
  });

  List<double> getMonthlySummary() {
    return List.generate(12, (index) => data[index + 1]!.toDouble());
  }
}
