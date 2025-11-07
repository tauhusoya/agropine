import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // Track if current login is a first-time signup
  bool _isFirstTimeSignup = false;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Check if this is a first-time signup
  bool get isFirstTimeSignup => _isFirstTimeSignup;

  // Reset first-time signup flag
  void resetFirstTimeSignupFlag() {
    _isFirstTimeSignup = false;
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String accountType,
    String? businessNumber,
  }) async {
    try {
      // Check if email is already registered
      final signInMethods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
      
      // If email exists with Google, link password auth to that account
      if (signInMethods.contains('google.com')) {
        // User needs to sign in with Google first, then link password
        throw 'This email is registered with Google Sign-In. Please sign in with Google first, then add a password in settings.';
      }
      
      // If email exists with password, they should sign in instead
      if (signInMethods.isNotEmpty && signInMethods.contains('password')) {
        throw 'This email is already registered. Please sign in instead.';
      }

      // Create new account with email and password
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'accountType': accountType,
        'businessNumber': businessNumber ?? '',
        'hasSeenWelcome': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update user profile display name
      await userCredential.user!.updateDisplayName('$firstName $lastName');

      // Mark as first-time signup
      _isFirstTimeSignup = true;

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw 'This email is already registered. Please sign in instead.';
      }
      throw _handleAuthException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  // Login with email and password
  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Password reset error: $e');
      throw 'Failed to send password reset email. Please try again.';
    }
  }

  // Alternative: Allow user to sign in with email and then update password
  Future<void> updatePasswordAfterVerification({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      // Firebase's sendPasswordResetEmail is the standard way
      // Users click the link in their email to reset password
      // This custom code approach requires Cloud Functions backend
      throw 'Please check your email for the password reset link. Click the link to complete the password reset.';
    } catch (e) {
      throw e.toString();
    }
  }

  // Confirm password reset with code and new password
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      await _firebaseAuth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  // Sign in anonymously for guest users
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _firebaseAuth.signInAnonymously();
    } catch (e) {
      throw 'Failed to sign in as guest. Please try again.';
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      throw 'Failed to fetch user data.';
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(uid).update(updateData);
    } catch (e) {
      throw 'Failed to update profile.';
    }
  }

  // Check if email exists
  Future<bool> isEmailRegistered(String email) async {
    try {
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      throw 'Failed to check email. Please try again.';
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google sign-in cancelled by user';
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential;
      
      try {
        // Try to sign in with Google
        userCredential = await _firebaseAuth.signInWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        // If account already exists with different auth method, link the accounts
        if (e.code == 'account-exists-with-different-credential') {
          // Get the email from Google account
          final email = googleUser.email;
          
          // Check what auth methods exist for this email
          final signInMethods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
          
          // If email has password method, we need to re-authenticate first
          if (signInMethods.contains('password')) {
            // For security, user must sign in with password first, then we link
            throw 'This email is registered with a password. Please sign in with your password first, then link your Google account in settings.';
          }
          
          rethrow;
        }
        rethrow;
      }

      // Store user data in Firestore if new user
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (!userDoc.exists) {
        final names = (userCredential.user?.displayName ?? '').split(' ');
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'firstName': names.isNotEmpty ? names[0] : '',
          'lastName': names.length > 1 ? names.sublist(1).join(' ') : '',
          'email': userCredential.user?.email ?? '',
          'accountType': 'individual',
          'businessNumber': '',
          'photoUrl': userCredential.user?.photoURL ?? '',
          'hasSeenWelcome': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        // Mark as first-time signup
        _isFirstTimeSignup = true;
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      await _googleSignIn.signOut();
      throw _handleAuthException(e);
    } catch (e) {
      await _googleSignIn.signOut();
      throw e.toString();
    }
  }

  // Check if current user has password auth method
  Future<bool> hasPasswordAuth() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;
      
      final signInMethods = await _firebaseAuth.fetchSignInMethodsForEmail(user.email ?? '');
      return signInMethods.contains('password');
    } catch (e) {
      return false;
    }
  }

  // Set password for current user (for Google-only accounts)
  Future<void> setPasswordForCurrentUser(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw 'No user logged in';
      }

      // Create email credential with current user's email
      final emailCredential = EmailAuthProvider.credential(
        email: user.email ?? '',
        password: password,
      );

      // Link the password credential to current user
      await user.linkWithCredential(emailCredential);
      
      print('Password set successfully for user');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'Password is too weak. Use at least 6 characters.';
      } else if (e.code == 'email-already-in-use') {
        throw 'This email already has a password account.';
      } else if (e.code == 'credential-already-in-use') {
        throw 'This password is already in use.';
      }
      throw _handleAuthException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  // Handle Firebase Auth Exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An authentication error occurred. Please try again.';
    }
  }
}
