// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:math';

import 'package:SportGrounds/api/google_signin_api.dart';
import 'package:SportGrounds/model/stadium.dart';
import 'package:SportGrounds/providers/favoritesProvider.dart';
import 'package:SportGrounds/providers/locationPermissionProvider.dart';
import 'package:SportGrounds/screens/logged_in_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SportGrounds/providers/usersProvider.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

import '../model/constants.dart';

RegExp numericRegExp = RegExp(r'^[0-9]+$');

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _twoAuthForm = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredPhoneNumber = "";
  var _twoAuthCode = "";
  var _error;
  var _userPrefrences = "";
  var _isLoading = false;
  var _isLoading_checkAuth = false;
  bool auth_success = false;
  bool isValid = false;
  var uuid = "";
  var userType = "";
  bool _connectionLost = false;
  String _errorMEssage = "";
  String preferencesString = "";
  List<Stadium> _favoritesStadiums = [];
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '630533245227-f7rj997qs8075alurbhbg3c79vaci4p1.apps.googleusercontent.com',
  );

  String generatePreferencesString(bool hasBathroom, bool hasPool,
      bool hasLights, bool hasFreeParking, bool hasFreeEquipment) {
    return 'Bathroom-${hasBathroom ? 1 : 0},Pool-${hasPool ? 1 : 0},Lights-${hasLights ? 1 : 0},Free Parking-${hasFreeParking ? 1 : 0},Sport equipment-${hasFreeEquipment ? 1 : 0}';
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371.0; // Earth radius in kilometers

    // Convert latitude and longitude from degrees to radians
    lat1 = _degreesToRadians(lat1);
    lon1 = _degreesToRadians(lon1);
    lat2 = _degreesToRadians(lat2);
    lon2 = _degreesToRadians(lon2);

    // Haversine formula
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance; // Distance in kilometers
  }

  Future<void> googleSignIn(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final user = await GoogleSigninApi.login();

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sign in failed')));
    } else {
      setState(() {
        ref
            .read(userSingletonProvider.notifier)
            .AuthSucceed(user.displayName!, user.id, "regular", "", true);
        Navigator.pop(context, "signedIn");
      });
      print("user");
      print(user.id);

      /*Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoggedInPage(user: user),
        ),
      );*/
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<bool?> _getFavorites() async {
    final url = Uri.http(httpIP, 'api/get_user_favorites');
    try {
      Map<String, dynamic> requestBody = {
        "user_id": ref.read(userSingletonProvider).id,
      };

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode >= 400 || response.statusCode < 200) {
        print(response.body);
        return false;
      } else {
        final List<dynamic> listData = json.decode(response.body);
        final List<Stadium> loadedItems = [];

        for (final item in listData) {
          double? distance; // Initialize distance here for each stadium

          if (ref.read(locationPermissionProvider).permission) {
            double stadiumLatitude = double.parse(item['latitude']);
            double stadiumLongitude = double.parse(item['longitude']);
            distance = calculateDistance(
              ref.read(locationPermissionProvider).latitude!,
              ref.read(locationPermissionProvider).longitude!,
              stadiumLatitude,
              stadiumLongitude,
            );
          }
          loadedItems.add(
            Stadium(
              id: item['uid'],
              title: item['name'],
              location: item['location'],
              imagePath: item['imageURL'],
              latitude: double.parse(item['latitude']),
              longitude: double.parse(item['longitude']),
              type: item['sport_type'],
              distance:
                  distance ?? 0.0, // Use a default value if distance is null
              // Ensure price is parsed as double
              rating: '5',
            ),
          );
        }
        setState(() {
          _favoritesStadiums = loadedItems;
        });
        ref
            .read(favoriteStadiumsProvider.notifier)
            .addFavoriteStadiums(_favoritesStadiums);
      }
    } catch (error) {
      print("error");
      print("Error: $error");
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    print(_isLoading);
    return Scaffold(
      appBar: AppBar(
        title: const Text("sign in"),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      top: 30,
                      bottom: 20,
                      left: 20,
                      right: 20,
                    ),
                    width: 200,
                    child: Image.asset('assets/images/chat.png'),
                  ),
                  Card(
                    margin: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _form,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'UserName',
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a Username.';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  _enteredEmail = newValue!;
                                },
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'password',
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 6) {
                                    return 'Password must be at least 6 charchters long.';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  _enteredPassword = newValue!;
                                },
                              ),
                              !_isLogin
                                  ? TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'phone number',
                                      ),
                                      obscureText: false,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().length > 10 ||
                                            !numericRegExp.hasMatch(value)) {
                                          return 'enter a valid phone number';
                                        }
                                        return null;
                                      },
                                      onSaved: (newValue) {
                                        _enteredPhoneNumber = newValue!;
                                      },
                                    )
                                  : const SizedBox(
                                      height: 12,
                                    ),
                              const SizedBox(
                                height: 12,
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  if (!_isLogin) {
                                    auth_success = await _createAccount();
                                    if (_connectionLost == true) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Connection Lost to server!'),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    } else if (auth_success == false &&
                                        isValid == true) {
                                      setState(() {
                                        //  _form.currentState?.validate();
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'This phoneNumber / UserName already in use'),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    } else {
                                      if (auth_success == true &&
                                          isValid == true) {
                                        showPreferencesPopup(
                                            context); // Show preferences popup after successful signup
                                      }
                                    }
                                  } else {
                                    auth_success = await _logIn();
                                    if (auth_success) {
                                      ref
                                          .read(userSingletonProvider.notifier)
                                          .AuthSucceed(_enteredEmail, uuid,
                                              userType, _userPrefrences, false);

                                      setState(() {
                                        _isLoading = true;
                                      });
                                      print("HHHH");
                                      print(ref
                                          .read(userSingletonProvider)
                                          .authenticationVar);
                                      if (ref
                                              .read(userSingletonProvider)
                                              .authenticationVar ==
                                          "regular") {
                                        _getFavorites();
                                      }
                                      setState(() {
                                        false;
                                      });
                                      Navigator.pop(context, "signedIn");
                                    } else {
                                      if (!auth_success && isValid) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(_errorMEssage),
                                            duration:
                                                const Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                    }
                                  }

                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                child: Text(_isLogin ? 'Login' : 'Signup'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(_isLogin
                                    ? 'Create an account'
                                    : 'I already have an account'),
                              ),
                              Row(
                                children: [
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: EdgeInsets.only(left: 45),
                                    child: ElevatedButton(
                                        onPressed: () => googleSignIn(context),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 60,
                                              child: Image.asset(
                                                  'lib/images/google_logo.png'),
                                            ),
                                            Text('Sign in with google'),
                                          ],
                                        )),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ))
              : const SizedBox(),
        ],
      ),
    );
  }

  Future<bool> _updatePrefrence() async {
    final url = Uri.http(httpIP, 'api/update_preference');
    print(preferencesString);
    try {
      Map<String, dynamic> requestBody = {
        "username": _enteredEmail,
        "preference": preferencesString,
      };

      setState(() {
        _isLoading = true;
      });
      final response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        print(response.body);
        setState(() {
          _isLoading = false;
        });
        return false;
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print("error");
      print("Error: $error");
      setState(() {
        // Handle the error
      });
    }
    return true;
  }

  Future<bool> _createAccount() async {
    _connectionLost = false;
    isValid = _form.currentState!.validate();
    if (!isValid) {
      return false;
    }
    _form.currentState!.save();
    final url = Uri.http(httpIP, 'api/create_user');
    try {
      Map<String, dynamic> requestBody = {
        "username": _enteredEmail,
        "password": _enteredPassword,
        "phonenum": _enteredPhoneNumber
      };

      setState(() {
        _isLoading = true;
      });
      final response = await http
          .post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10))
          .catchError((error) {
        setState(() {
          _connectionLost = true;
          auth_success = false;
          _isLoading = false;
        });
      });

      if (response.statusCode >= 400) {
        setState(() {
          auth_success = false;
          _isLoading = false;
        });
        return auth_success;
      } else {
        setState(() {
          auth_success = true;
          _isLoading = false;
        });

        if (auth_success == true && isValid == true) {
          showPreferencesPopup(
              context); // Show preferences popup after successful signup
        }
      }
    } catch (error) {
      print("error");
      print("Error: $error");
      setState(() {
        // Handle the error
      });
    }
    return auth_success;
  }

  void showSignUpConfirmationPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Welcome $_enteredEmail'),
          content: const Text(
              'You are being redirected to the homePage, you can sign in into your account now!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _logIn() async {
    isValid = _form.currentState!.validate();
    if (!isValid) {
      return false;
    }
    _form.currentState!.save();
    final url = Uri.http(httpIP, 'api/user_verfication');
    try {
      Map<String, dynamic> requestBody = {
        "username": _enteredEmail,
        "password": _enteredPassword,
      };

      _form.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      setState(() {
        _isLoading = false;
      });
      print(response.body);
      if (response.statusCode > 401) {
        _errorMEssage = "Connection Error";
        return false;
      } else {
        if (response.statusCode == 401) {
          _errorMEssage = "Wrong Credentials";
          return false;
        }
      }
      if (response.statusCode != 200) {
        _errorMEssage = "Connection Faliure";
        return false;
      } else {
        print("hiii");

       setState(() {
          final Map<String, dynamic> listData = json.decode(response.body);
          uuid = listData['userid'];
          userType = listData['user_type'];
          _userPrefrences = listData['preferences'];
          ref.read(userSingletonProvider.notifier).AuthSucceed(
              _enteredEmail, uuid, userType, _userPrefrences, false);
        });
        print(_userPrefrences);
        return true;
      }
    } catch (error) {
      print(error);
      return true;
    }
  }

  Future<bool> _showPopup(BuildContext context) async {
    await _askForAuthCode();
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible:
            false, // Prevents closing the dialog by tapping outside
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Stack(
                children: [
                  AlertDialog(
                    title: const Text('Two Factor Authentication'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            'We sent a pin to $_enteredPhoneNumber \nplease write it:'),
                        const SizedBox(height: 20),
                        Form(
                          key: _twoAuthForm,
                          child: TextFormField(
                            onSaved: (newValue) {
                              _twoAuthCode = newValue!;
                            },
                            decoration:
                                const InputDecoration(labelText: 'Enter Pin'),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Add functionality for the button in the popup dialog
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: const Text('Back'),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: _isLoading_checkAuth
                                ? const Text("Submit")
                                : ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        _isLoading_checkAuth = true;
                                      });
                                      _twoAuthForm.currentState!.save();
                                      bool authSuccess = await _checkSubmit();
                                      print(authSuccess);
                                      if (authSuccess == true) {
                                        //
                                      }
                                      setState(() {
                                        _isLoading_checkAuth = false;
                                      });
                                      //Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: const Text('Submit'),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_isLoading_checkAuth)
                    const Center(child: CircularProgressIndicator()),
                ],
              );
            },
          );
        },
      );
    }
    return true;
  }

  Future<bool> _askForAuthCode() async {
    final url =
        Uri.http('10.0.0.24:5000', 'api/send-auth-code/$_enteredPhoneNumber');
    print(url);
    final http.Response response;

    try {
      print("sending request");
      response = await http.get(url);
      print("retriving request");
      print(response);
      if (response.statusCode >= 400) {
        {
          print("errror");
          setState(() {
            //_isLoading = false;
            _error = 'failed to fetch data. please try again later';
          });
          return false;
        }
      }
      print(response);
      if (response.body == 'null') {
        setState(() {
          //_isLoading = false;
        });
        return false;
      }
      print(response.body);
    } catch (error) {
      print("error!!!! $error");
      //setState(() {
      //_isLoading = false;
      //_error = 'failed to fetch data. please try again later';
      //});
    }
    return true;
    //_isLoading = false;
  }

  Future<bool> _checkSubmit() async {
    final url = Uri.http('10.0.0.24:5000',
        'api/confirm-auth-code/$_enteredPhoneNumber/$_twoAuthCode');
    print(url);
    final http.Response response;
    try {
      print("sending request");
      response = await http.get(url);
      print("retriving request");
      print(response);
      if (response.statusCode >= 400) {
        {
          print("errror");
          setState(() {
            _isLoading_checkAuth = false;
            _error = 'failed to fetch data. please try again later';
          });

          return false;
        }
      }
      print(response);
      if (response.body == 'null') {
        setState(() {
          _isLoading_checkAuth = false;
        });
        return false;
      }
      print(response.body);
    } catch (error) {
      print("error!!!! $error");
      setState(() {
        _isLoading_checkAuth = false;
        _error = 'failed to fetch data. please try again later';
      });
      return false;
    }
    _isLoading_checkAuth = false;
    return true;
  }

  void showPreferencesPopup(BuildContext context) {
    bool hasBathroom = false;
    bool hasPool = false;
    bool hasLights = false;
    bool hasFreeParking = false;
    bool hasFreeEquipment = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Choose Your Preferences'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      'You can change these preferences in the Settings section later.'),
                  CheckboxListTile(
                    title: const Text('Bathroom'),
                    value: hasBathroom,
                    onChanged: (bool? value) {
                      setState(() {
                        hasBathroom = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Pool'),
                    value: hasPool,
                    onChanged: (bool? value) {
                      setState(() {
                        hasPool = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Lights'),
                    value: hasLights,
                    onChanged: (bool? value) {
                      setState(() {
                        hasLights = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Sport equipment'),
                    value: hasFreeEquipment,
                    onChanged: (bool? value) {
                      setState(() {
                        hasFreeEquipment = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Free Parking'),
                    value: hasFreeParking,
                    onChanged: (bool? value) {
                      setState(() {
                        hasFreeParking = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  // API for prefrence sending
                  onPressed: () async {
                    preferencesString = generatePreferencesString(
                      hasBathroom,
                      hasPool,
                      hasLights,
                      hasFreeParking,
                      hasFreeEquipment,
                    );
                    await _updatePrefrence();
                    print(preferencesString); // Print the preferences string
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    showSignUpConfirmationPopup(context);
                    // Show the confirmation popup after preferences
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
