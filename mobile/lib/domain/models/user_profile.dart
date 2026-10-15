class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String? phoneNumber;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime? lastSignInAt;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.phoneNumber,
    this.fcmToken,
    required this.createdAt,
    this.lastSignInAt,
  });

  bool get hasLinkedPhone => phoneNumber != null && phoneNumber!.trim().isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'fcmToken': fcmToken,
      'createdAt': createdAt.toIso8601String(),
      'lastSignInAt': lastSignInAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      // Handle Firestore Timestamp or DateTime
      try {
        return (val as dynamic).toDate();
      } catch (_) {
        return DateTime.now();
      }
    }

    return UserProfile(
      uid: uid,
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      fcmToken: map['fcmToken'],
      createdAt: parseDate(map['createdAt']),
      lastSignInAt: map['lastSignInAt'] != null ? parseDate(map['lastSignInAt']) : null,
    );
  }

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? phoneNumber,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }
}
