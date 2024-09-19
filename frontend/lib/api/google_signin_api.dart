

import 'package:google_sign_in/google_sign_in.dart';

class GoogleSigninApi {
  static const _clientIDWeb =
      "630533245227-pjrj247bfbl9atmnf23ce4dl3m50fo9c.apps.googleusercontent.com";

  static final _googleSignIn = GoogleSignIn(clientId: _clientIDWeb);

  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();

  static Future logout() => _googleSignIn.disconnect();
}
