import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/model/users.dart';

Users serverer = Users(
  id: "",
  phoneNumber: "",
  name: "",
  authenticationVar: "",
  password: "",
  preferences: "",
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

  void AuthSucceed(String email, String id, String userType, String preference) {
    print("what!!!");
    state = Users(
      authenticationVar: userType,
      name: email,
      phoneNumber: serverer.phoneNumber,
      id: id,
      password: serverer.password,
      preferences: preference
    );
  }

  void Logout() {
    state = Users(
      authenticationVar: "",
      name: "",
      phoneNumber: "",
      id: "",
      password: "",
    );
  }

  void removeErrorMessage(String message) {
    state = Users(
      name: "",
      authenticationVar: "",
      id: "",
      password: "",
      phoneNumber: "",
    );
  }

  /*void addPlace(String title, File image)
  {
    final newPlace = Place(title: title,image: image);
    state = [newPlace,...state];

  }*/
}

final userSingletonProvider =
    StateNotifierProvider<UserSingletonNotifier, Users>(
  (ref) => UserSingletonNotifier(),
);
