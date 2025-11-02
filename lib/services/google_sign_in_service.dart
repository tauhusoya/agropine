import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();

  late GoogleSignIn _googleSignIn;

  GoogleSignInService._internal() {
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'profile',
      ],
    );
  }

  factory GoogleSignInService() {
    return _instance;
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account;
    } catch (error) {
      throw Exception('Failed to sign in with Google: $error');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      throw Exception('Failed to sign out: $error');
    }
  }

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  bool get isSignedIn => _googleSignIn.currentUser != null;

  Map<String, String?> getUserInfo() {
    final user = _googleSignIn.currentUser;
    return {
      'email': user?.email,
      'displayName': user?.displayName,
      'photoUrl': user?.photoUrl,
    };
  }
}
