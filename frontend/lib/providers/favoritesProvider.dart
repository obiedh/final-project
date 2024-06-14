import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/stadium.dart';

class FavoriteStadiumNotifier extends StateNotifier<List<Stadium>> {
  FavoriteStadiumNotifier() : super([]);

  void clearFavorites() {
    state = [];
  }

  bool toggleStadiumFavoriteStatus(Stadium stadium) {
    bool stadiumIsFavorite = false;
    for (int i = 0; i < state.length; i++) {
      if (state[i].id == stadium.id) {
        stadiumIsFavorite = true;
        i = state.length;
      }
    }

    if (stadiumIsFavorite) {
      state = state.where((s) => s.id != stadium.id).toList();
      return false;
    } else {
      state = [...state, stadium];
      return true;
    }
  }

  // Method to add a list of favorite stadiums
  void addFavoriteStadiums(List<Stadium> stadiums) {
    state = [...state, ...stadiums];
  }
}

final favoriteStadiumsProvider =
    StateNotifierProvider<FavoriteStadiumNotifier, List<Stadium>>((ref) {
  return FavoriteStadiumNotifier();
});
