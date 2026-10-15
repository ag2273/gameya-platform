import 'dart:async';
import '../../domain/models/user_profile.dart';

abstract class AuthService {
  Stream<UserProfile?> get authStateChanges;
  UserProfile? get currentUser;

  Future<UserProfile> signInWithGoogle();
  Future<void> signOut();
  Future<UserProfile> updateUserProfile(UserProfile profile);
  Future<void> updatePhoneNumber(String uid, String phoneNumber);
}

class MockAuthService implements AuthService {
  UserProfile? _currentUser;
  final StreamController<UserProfile?> _authController = StreamController<UserProfile?>.broadcast();

  MockAuthService({UserProfile? initialUser}) {
    _currentUser = initialUser;
  }

  @override
  Stream<UserProfile?> get authStateChanges => _authController.stream;

  @override
  UserProfile? get currentUser => _currentUser;

  @override
  Future<UserProfile> signInWithGoogle() async {
    // Simulates frictionless 1-tap Google Sign-In
    final profile = UserProfile(
      uid: 'google_test_uid_123',
      displayName: 'مستخدم تجريبي (أحمد)',
      email: 'ahmed.gameya@gmail.com',
      createdAt: DateTime.now(),
      lastSignInAt: DateTime.now(),
    );
    _currentUser = profile;
    _authController.add(_currentUser);
    return profile;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authController.add(null);
  }

  @override
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    _currentUser = profile;
    _authController.add(_currentUser);
    return profile;
  }

  @override
  Future<void> updatePhoneNumber(String uid, String phoneNumber) async {
    if (_currentUser != null && _currentUser!.uid == uid) {
      _currentUser = _currentUser!.copyWith(phoneNumber: phoneNumber);
      _authController.add(_currentUser);
    }
  }

  void dispose() {
    _authController.close();
  }
}
