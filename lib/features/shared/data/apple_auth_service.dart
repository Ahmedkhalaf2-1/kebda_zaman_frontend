import 'package:firebase_auth/firebase_auth.dart';

class AppleAuthException implements Exception {
  final String message;
  const AppleAuthException(this.message);

  @override
  String toString() => 'AppleAuthException: $message';
}

/// Opens Apple's native Firebase provider flow and returns a fresh Firebase
/// ID token for the backend exchange. A user cancellation returns `null`.
class AppleAuthService {
  final FirebaseAuth _firebaseAuth;

  AppleAuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<String?> signIn() async {
    final provider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');

    final UserCredential credential;
    try {
      credential = await _firebaseAuth.signInWithProvider(provider);
    } on FirebaseAuthException catch (e) {
      if (e.code.toLowerCase().contains('cancel')) return null;
      throw AppleAuthException('Firebase Apple sign-in failed: ${e.code}');
    } catch (e) {
      throw AppleAuthException('Apple authentication failed: $e');
    }

    final user = credential.user;
    if (user == null) {
      throw const AppleAuthException(
        'Firebase authentication returned no user',
      );
    }

    final String? idToken;
    try {
      idToken = await user.getIdToken(true);
    } catch (e) {
      throw AppleAuthException('Failed to obtain Firebase ID token: $e');
    }

    if (idToken == null || idToken.isEmpty) {
      throw const AppleAuthException('Firebase ID token was empty');
    }
    return idToken;
  }
}
