import '../../lib/domain/models/user_profile.dart';
import '../../lib/data/services/auth_service.dart';

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

void main() async {
  print('Starting AuthService unit test suite...');

  final authService = MockAuthService();

  // Test 1: Initial state is signed out
  print('Test 1: Initial user state should be null...');
  expect(authService.currentUser, null);

  // Test 2: Sign in with Google
  print('Test 2: Sign in with Google...');
  final profile = await authService.signInWithGoogle();
  expect(profile.email, 'ahmed.gameya@gmail.com');
  expect(profile.displayName, 'مستخدم تجريبي (أحمد)');
  expect(authService.currentUser?.uid, 'google_test_uid_123');
  expectTrue(!profile.hasLinkedPhone, 'Initially phone is unlinked');

  // Test 3: Link WhatsApp phone number
  print('Test 3: Link phone number...');
  await authService.updatePhoneNumber(profile.uid, '+201012345678');
  expect(authService.currentUser?.phoneNumber, '+201012345678');
  expectTrue(authService.currentUser!.hasLinkedPhone, 'Phone is now linked');

  // Test 4: Sign out
  print('Test 4: Sign out...');
  await authService.signOut();
  expect(authService.currentUser, null);

  authService.dispose();
  print('SUCCESS: All AuthService tests passed (4/4)!');
}
