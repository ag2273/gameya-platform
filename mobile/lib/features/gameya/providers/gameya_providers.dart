import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/firestore_gameya_repository.dart';
import '../../../domain/models/gameya.dart';
import '../../../domain/models/member_share.dart';
import '../../../domain/models/installment.dart';

final firestoreRepositoryProvider = Provider<FirestoreGameyaRepository>((ref) {
  return FirestoreGameyaRepository();
});

final activeGameyaIdProvider = StateProvider<String>((ref) {
  return 'gameya_family_2026';
});

final activeMonthProvider = StateProvider<int>((ref) {
  return 3;
});

final activeGameyaStreamProvider = StreamProvider<Gameya?>((ref) {
  final repo = ref.watch(firestoreRepositoryProvider);
  final id = ref.watch(activeGameyaIdProvider);
  return repo.streamGameya(id);
});

final activeMembersStreamProvider = StreamProvider<List<MemberShare>>((ref) {
  final repo = ref.watch(firestoreRepositoryProvider);
  final id = ref.watch(activeGameyaIdProvider);
  return repo.streamMembers(id);
});

final activeInstallmentsStreamProvider = StreamProvider<List<Installment>>((ref) {
  final repo = ref.watch(firestoreRepositoryProvider);
  final id = ref.watch(activeGameyaIdProvider);
  final month = ref.watch(activeMonthProvider);
  return repo.streamInstallments(id, month);
});
