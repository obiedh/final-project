class Users {
  Users({
    required this.name,
    required this.id,
    required this.password,
    required this.phoneNumber,
    required this.authenticationVar,
    this.preferences,
  });
  String id;
  String name;
  String password;
  String phoneNumber;
  String authenticationVar;
  String? preferences;
}


/*
    final String ServerIP;
    final String name;
    
    ServerModel({
    required this.ServerIP,
    required this.name,
    });
*/