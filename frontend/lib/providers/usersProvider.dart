import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SportGrounds/model/users.dart';

Users serverer = Users(
  id: "",
  phoneNumber: "",
  name: "",
  authenticationVar: "",
  password: "",
  preferences: "",
  sso: false,
);

class UserSingletonNotifier extends StateNotifier<Users> {
  UserSingletonNotifier() : super(serverer);

  String signInWithEmailAndPassword(
      {required String email, required String password}) {
    // do something with server
    // take the stuff from state
    return "hey";
  }

  String createUserWithEmailAndPassword(
      {required String email, required String password}) {
    // do something with server
    // take the stuff from state
    return "hey";
  }

  String createUserWithTwoFactor(
      {required String username,
      required String password,
      required String phoneNumber}) {
    return "piere";
  }

  void AuthSucceed(
      String email, String id, String userType, String preference, bool sso) {
    print("what!!!");
    state = Users(
      authenticationVar: userType,
      name: email,
      phoneNumber: serverer.phoneNumber,
      id: id,
      password: serverer.password,
      preferences: preference,
      sso: sso,
    );
  }

  void Logout() {
    state = Users(
      authenticationVar: "",
      name: "",
      phoneNumber: "",
      id: "",
      password: "",
      preferences: "",
    );
  }

  void removeErrorMessage(String message) {
    state = Users(
      name: "",
      authenticationVar: "",
      id: "",
      password: "",
      phoneNumber: "",
      preferences: "",
    );
  }

  void updatePreferences(String newPreferences) {
    state = Users(
      authenticationVar: state.authenticationVar,
      name: state.name,
      phoneNumber: state.phoneNumber,
      id: state.id,
      password: state.password,
      preferences: newPreferences,
    );
  }
}

final userSingletonProvider =
    StateNotifierProvider<UserSingletonNotifier, Users>(
  (ref) => UserSingletonNotifier(),
);
