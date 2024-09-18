import 'package:SportGrounds/screens/Stadiums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:SportGrounds/model/filters.dart';

DateTime date = DateTime.now();
Filters filters = Filters(
  date: formatDateTimeToDateString(date),
  startTime: "02:00",
  endTime: "10:00",
  location: "All",
  availableTime: [
    {
      'time': "14:00-16:00",
      'price': '50',
    },
    {'time': "16:00-17:00", 'price': '60'}
  ], // Change here
  dateForInit: DateTime.now(),
  isFilterOn: false,
);

class FiltersSingletonNotifier extends StateNotifier<Filters> {
  FiltersSingletonNotifier() : super(filters);

  String formatDateTimeToDateString(DateTime dateTime) {
    // Create a date format with the desired format (yyyy-MM-dd)
    final dateFormat = DateFormat('dd.M.yyyy');

    // Format the DateTime to a string with the specified format
    return dateFormat.format(dateTime);
  }

  void restoreFilters() {
    state = Filters(
      date: state.date,
      startTime: "02:00",
      endTime: "10:00",
      location: "All",
      availableTime: state.availableTime,
      dateForInit: DateTime.now(),
      isFilterOn: false,
    );
  }

  void appliedDateFilter(DateTime date) {
    state = Filters(
      date: formatDateTimeToDateString(date),
      startTime: state.startTime,
      endTime: state.endTime,
      location: state.location,
      availableTime: state.availableTime,
      dateForInit: date,
    );
  }

  void appliedLocationFilter(String location) {
    state = Filters(
      date: state.date,
      startTime: TimeOfDay.now().toString(),
      endTime: state.endTime,
      location: location,
      availableTime: state.availableTime,
      dateForInit: state.dateForInit,
    );
  }

  void appliedAvailableTime(List<Map<String, String>> availableTime) {
    // Change here
    state = Filters(
      date: state.date,
      startTime: state.startTime,
      endTime: state.endTime,
      location: state.location,
      availableTime: availableTime,
      dateForInit: state.dateForInit,
    );
  }

  void turnFiltersStatus(bool filters) {
    state = Filters(
      date: state.date,
      startTime: state.startTime,
      endTime: state.endTime,
      location: state.location,
      availableTime: state.availableTime,
      dateForInit: state.dateForInit,
      isFilterOn: filters,
    );
  }
}

final filterSingletonProvider =
    StateNotifierProvider<FiltersSingletonNotifier, Filters>(
  (ref) => FiltersSingletonNotifier(),
);
