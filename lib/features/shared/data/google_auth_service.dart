import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Thrown when Google/Firebase authentication fails for a reason other than
/// the user cancelling account selection. Cancellation is not an error — see
/// [GoogleAuthService.signIn], which returns `null` for it instead of
/// throwing, mirroring `GoogleSignIn.signIn()`'s own null-on-cancel contract.
class GoogleAuthException implements Exception {
  final String message;
  const GoogleAuthException(this.message);

  @override
  String toString() => 'GoogleAuthException: $message';
}

/// Drives the client-side half of Google Sign-In: opens the account picker,
/// exchanges the Google credential for a Firebase session, and returns a
/// fresh Firebase ID token. That token is the ONLY thing callers get back —
/// it is used once to exchange for the backend's own JWT session
/// (`POST /auth/google`) and is never stored, logged in full, or used as an
/// API bearer token itself.
class GoogleAuthService {
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _firebaseAuth;

  GoogleAuthService({GoogleSignIn? googleSignIn, FirebaseAuth? firebaseAuth})
    : _googleSignIn = googleSignIn ?? GoogleSignIn(),
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Runs the full Google → Firebase exchange and returns a fresh Firebase
  /// ID token, or `null` if the user cancelled account selection (not an
  /// error — callers must not show an error message for a `null` return).
  ///
  /// Throws [GoogleAuthException] for every other failure mode: Google
  /// authentication failure, Firebase credential exchange failure, a null
  /// Firebase user, or a null/empty ID token.
  Future<String?> signIn() async {
    final GoogleSignInAccount? googleUser;
    try {
      googleUser = await _googleSignIn.signIn();
    } catch (e) {
      throw GoogleAuthException('Google authentication failed: $e');
    }

    // The user closed the account picker without choosing an account —
    // google_sign_in's own cancellation signal, not an error.
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth;
    try {
      googleAuth = await googleUser.authentication;
    } catch (e) {
      throw GoogleAuthException('Failed to obtain Google credentials: $e');
    }

    if (googleAuth.idToken == null && googleAuth.accessToken == null) {
      throw const GoogleAuthException(
        'Google returned no usable authentication tokens',
      );
    }

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    final UserCredential userCredential;
    try {
      userCredential = await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw GoogleAuthException('Firebase sign-in failed: ${e.code}');
    } catch (e) {
      throw GoogleAuthException('Firebase sign-in failed: $e');
    }

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw const GoogleAuthException(
        'Firebase authentication returned no user',
      );
    }

    final String? idToken;
    try {
      // Force a fresh token rather than trusting any cached one — this is
      // used immediately, once, for the backend exchange.
      idToken = await firebaseUser.getIdToken(true);
    } catch (e) {
      throw GoogleAuthException('Failed to obtain Firebase ID token: $e');
    }

    if (idToken == null || idToken.isEmpty) {
      throw const GoogleAuthException('Firebase ID token was empty');
    }

    return idToken;
  }

  /// Best-effort sign-out from both Google and Firebase. Never throws —
  /// logout must proceed (and backend tokens must always be cleared)
  /// regardless of whether this succeeds.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    try {
      await _firebaseAuth.signOut();
    } catch (_) {}
  }
}
