import 'package:SportGrounds/model/stadium.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List<Stadium> stadiums = [];

// Define a StateNotifier for managing a list of Stadiums
class StadiumListNotifier extends StateNotifier<List<Stadium>> {
  StadiumListNotifier() : super([]);

  // Add a new stadium to the list
  void addStadium(Stadium stadium) {
    state = [...state, stadium];
  }

  // Remove a stadium from the list by id
  void removeStadium(String id) {
    state = state.where((stadium) => stadium.id != id).toList();
  }

  void clearStadiums() {
    state = [];
  }

  // Set the list of stadiums to a new list
  void setStadiums(List<Stadium> newStadiums) {
    state = newStadiums;
  }

  // Update the availability of a stadium by id

  void updateStadiumAvailability(
    String id,
    String newAvailability,
  ) {
    state = state.map((stadium) {
      if (stadium.id == id) {
        return stadium.copyWith(
          availability: newAvailability,
        );
      }
      return stadium;
    }).toList();
  }

  void updateStadiumDetails(
    String id,
    String? newTitle,
    String? newUtilities,
  ) {
    state = state.map((stadium) {
      if (stadium.id == id) {
        return stadium.copyWith(
          title: newTitle,
          utilities: newUtilities,
        );
      }
      return stadium;
    }).toList();
  }
}

// Define a provider for the StadiumListNotifier
final stadiumListProvider =
    StateNotifierProvider<StadiumListNotifier, List<Stadium>>((ref) {
  return StadiumListNotifier();
});
