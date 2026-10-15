import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/utils/whatsapp_helper.dart';

enum UserRole { organizer, member }

class AppUser {
  final String uid;
  final String displayName;
  final String phone;
  final UserRole role;

  AppUser({
    required this.uid,
    required this.displayName,
    required this.phone,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'phone': phone,
      'role': role.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      displayName: map['displayName'] ?? 'مستخدم',
      phone: map['phone'] ?? '',
      role: map['role'] == 'organizer' ? UserRole.organizer : UserRole.member,
    );
  }
}

class FirebaseAuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AppUser? _currentAppUser;
  final StreamController<AppUser?> _userController = StreamController<AppUser?>.broadcast();

  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<AppUser?> get userStream => _userController.stream;
  AppUser? get currentAppUser => _currentAppUser;

  /// Sign in with phone number, display name, and role.
  Future<AppUser> signIn({
    required String phone,
    required String displayName,
    required UserRole role,
  }) async {
    final normalizedPhone = WhatsAppHelper.normalizePhone(phone);
    
    // Ensure Firebase Auth session
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      final cred = await _auth.signInAnonymously();
      firebaseUser = cred.user;
    }

    final uid = firebaseUser?.uid ?? 'user_${DateTime.now().millisecondsSinceEpoch}';

    final appUser = AppUser(
      uid: uid,
      displayName: displayName,
      phone: normalizedPhone,
      role: role,
    );

    // Save profile to Firestore
    try {
      await _firestore.collection('users').doc(uid).set(appUser.toMap(), SetOptions(merge: true));
    } catch (e) {
      // Continue even if offline
    }

    _currentAppUser = appUser;
    _userController.add(_currentAppUser);
    return appUser;
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    _currentAppUser = null;
    _userController.add(null);
  }
}
