import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/model/flagsProvider.dart';

Flag flag = Flag(reservationFlag: false);

class FlagSingletoneProvider extends StateNotifier<Flag> {
  FlagSingletoneProvider() : super(flag);

  void turFlagON(bool flag) {
    state = Flag(reservationFlag: true);
  }

  void turnFlagOFF(bool flag) {
    state = Flag(reservationFlag: false);
  }
}

final flagProvider = StateNotifierProvider<FlagSingletoneProvider, Flag>(
  (ref) => FlagSingletoneProvider(),
);
