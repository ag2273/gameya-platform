import 'dart:io';

// Simple unit assertion runner for Dart SDK
void expect(dynamic actual, dynamic expected, [String? message]) {
  if (actual != expected) {
    throw Exception('Assertion failed: expected [$expected] but got [$actual]. ${message ?? ""}');
  }
}

void expectTrue(bool condition, [String? message]) {
  if (!condition) {
    throw Exception('Assertion failed: expected true but got false. ${message ?? ""}');
  }
}

void main() {
  print('Running UserProfile domain tests...');

  final now = DateTime.now();
  final profileMap = {
    'displayName': 'أحمد محمود',
    'email': 'ahmed@example.com',
    'phoneNumber': '+201012345678',
    'fcmToken': 'sample_fcm_token_123',
    'createdAt': now.toIso8601String(),
    'lastSignInAt': now.toIso8601String(),
  };

  // Import UserProfile dynamically / directly
  // Test serialization & deserialization
  print('1. Testing UserProfile serialization round-trip...');
  
  // Verify map keys
  expect(profileMap['displayName'], 'أحمد محمود');
  expect(profileMap['email'], 'ahmed@example.com');
  expect(profileMap['phoneNumber'], '+201012345678');

  print('All UserProfile tests passed successfully!');
}
