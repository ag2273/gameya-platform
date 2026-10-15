import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/gameya.dart';
import '../../domain/models/member_share.dart';
import '../../domain/models/installment.dart';

class FirestoreGameyaRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreGameyaRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Ensures an authenticated session (anonymous or Google) to satisfy security rules.
  Future<User?> ensureAuthenticated() async {
    try {
      if (_auth.currentUser != null) {
        return _auth.currentUser;
      }
      final cred = await _auth.signInAnonymously();
      return cred.user;
    } catch (e) {
      // In case offline or rules permit unauthenticated
      return null;
    }
  }

  /// Streams the active Gameya document in real-time.
  Stream<Gameya?> streamGameya(String gameyaId) {
    return _firestore
        .collection('gameyas')
        .doc(gameyaId)
        .snapshots()
        .map<Gameya?>((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return Gameya.fromMap(snapshot.data()!, snapshot.id);
    }).handleError((error) {
      // Gracefully prevent unhandled permission-denied crash
      return null;
    });
  }

  /// Streams all member shares for a given Gameya.
  Stream<List<MemberShare>> streamMembers(String gameyaId) {
    return _firestore
        .collection('gameyas')
        .doc(gameyaId)
        .collection('members')
        .snapshots()
        .map<List<MemberShare>>((snapshot) {
      return snapshot.docs
          .map((doc) => MemberShare.fromMap(doc.data(), doc.id))
          .toList();
    }).handleError((error) {
      return <MemberShare>[];
    });
  }

  /// Streams installments for a specific month.
  Stream<List<Installment>> streamInstallments(String gameyaId, int monthNumber) {
    return _firestore
        .collection('gameyas')
        .doc(gameyaId)
        .collection('installments')
        .where('monthNumber', isEqualTo: monthNumber)
        .snapshots()
        .map<List<Installment>>((snapshot) {
      return snapshot.docs
          .map((doc) => Installment.fromMap(doc.data(), doc.id))
          .toList();
    }).handleError((error) {
      return <Installment>[];
    });
  }

  /// Creates a real production Gameya, saving all assigned member shares and generating all installments.
  Future<void> createRealGameya({
    required Gameya gameya,
    required List<MemberShare> members,
  }) async {
    final batch = _firestore.batch();
    
    // 1. Gameya document
    final gameyaRef = _firestore.collection('gameyas').doc(gameya.id);
    batch.set(gameyaRef, gameya.toMap());

    // 2. Members subcollection
    for (final member in members) {
      final memberRef = gameyaRef.collection('members').doc(member.id);
      batch.set(memberRef, member.toMap());

      // 3. Generate installments for each month (1 to gameya.totalMonths)
      for (int m = 1; m <= gameya.totalMonths; m++) {
        final installmentId = 'inst_${gameya.id}_${member.id}_m$m';
        final instRef = gameyaRef.collection('installments').doc(installmentId);
        final dueDate = gameya.startDate.add(Duration(days: 30 * (m - 1)));
        
        batch.set(instRef, {
          'id': installmentId,
          'gameyaId': gameya.id,
          'memberShareId': member.id,
          'monthNumber': m,
          'amount': member.installmentAmount,
          'status': InstallmentStatus.pending.name,
          'dueDate': dueDate.toIso8601String(),
          'paidAt': null,
          'verifiedBy': null,
        });
      }
    }

    await batch.commit();
  }

  /// Streams all Gameyas where user is the organizer.
  Stream<List<Gameya>> streamOrganizerGameyas(String organizerUid) {
    return _firestore
        .collection('gameyas')
        .where('organizerId', isEqualTo: organizerUid)
        .snapshots()
        .map<List<Gameya>>((snapshot) {
      return snapshot.docs
          .map((doc) => Gameya.fromMap(doc.data(), doc.id))
          .toList();
    }).handleError((_) => <Gameya>[]);
  }

  /// Streams member shares matching phone number.
  Stream<List<MemberShare>> streamMemberSharesByPhone(String phone) {
    return _firestore
        .collectionGroup('members')
        .where('phone', isEqualTo: phone)
        .snapshots()
        .map<List<MemberShare>>((snapshot) {
      return snapshot.docs
          .map((doc) => MemberShare.fromMap(doc.data(), doc.id))
          .toList();
    }).handleError((_) => <MemberShare>[]);
  }


  /// 1-Tap Toggle between Pending and Paid directly in live Firestore.
  Future<void> toggleInstallmentStatus({
    required String gameyaId,
    required String installmentId,
    required InstallmentStatus newStatus,
    String? verifierId,
  }) async {
    final docRef = _firestore
        .collection('gameyas')
        .doc(gameyaId)
        .collection('installments')
        .doc(installmentId);

    final updateData = <String, dynamic>{
      'status': newStatus.name,
    };

    if (newStatus == InstallmentStatus.paid) {
      updateData['paidAt'] = DateTime.now().toIso8601String();
      if (verifierId != null) updateData['verifiedBy'] = verifierId;
    } else {
      updateData['paidAt'] = null;
      updateData['verifiedBy'] = null;
    }

    await docRef.update(updateData);
  }

  /// 1-Tap Approve receipt in live Firestore.
  Future<void> approveReceipt({
    required String gameyaId,
    required String installmentId,
    required String organizerId,
  }) async {
    await _firestore
        .collection('gameyas')
        .doc(gameyaId)
        .collection('installments')
        .doc(installmentId)
        .update({
      'status': InstallmentStatus.paid.name,
      'verifiedBy': organizerId,
      'paidAt': DateTime.now().toIso8601String(),
    });
  }

  /// Reject receipt and prompt member to re-upload.
  Future<void> rejectReceipt({
    required String gameyaId,
    required String installmentId,
    required String reason,
  }) async {
    await _firestore
        .collection('gameyas')
        .doc(gameyaId)
        .collection('installments')
        .doc(installmentId)
        .update({
      'status': InstallmentStatus.pending.name,
      'rejectionReason': reason,
      'paidAt': null,
      'verifiedBy': null,
    });
  }

  /// Zero-cost receipt upload stored directly in Cloud Firestore (Spark plan).
  Future<void> uploadReceiptToFirestore({
    required String gameyaId,
    required String installmentId,
    required List<int> compressedBytes,
    required String filename,
  }) async {
    final base64Image = base64Encode(compressedBytes);
    final dataUri = 'data:image/jpeg;base64,$base64Image';

    // 1. Write receipt image document into `/receipts/{installmentId}`
    await _firestore.collection('receipts').doc(installmentId).set({
      'gameyaId': gameyaId,
      'installmentId': installmentId,
      'filename': filename,
      'base64Image': base64Image,
      'sizeBytes': compressedBytes.length,
      'uploadedAt': FieldValue.serverTimestamp(),
    });

    // 2. Update installment status to `review`
    await _firestore
        .collection('gameyas')
        .doc(gameyaId)
        .collection('installments')
        .doc(installmentId)
        .update({
      'status': InstallmentStatus.review.name,
      'receiptUrl': dataUri,
      'receiptUploadedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Seeds initial demo Gameya if database is empty, so user can immediately view live data.
  Future<void> seedInitialGameyaIfEmpty(String gameyaId) async {
    try {
      final doc = await _firestore.collection('gameyas').doc(gameyaId).get();
      if (doc.exists) return; // Already exists

      // 1. Create main Gameya document
      final gameya = Gameya(
        id: gameyaId,
        name: 'جمعية العائلة الكبرى (10 شهور)',
        organizerId: _auth.currentUser?.uid ?? 'organizer_ayman',
        totalPot: 50000.0,
        monthlyShareInstallment: 5000.0,
        totalMonths: 10,
        startDate: DateTime(2026, 1, 1),
        status: GameyaStatus.active,
        inviteCode: 'INV-FAMILY-2026',
        currency: 'ج.م',
        gracePeriodDays: 7,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('gameyas').doc(gameyaId).set(gameya.toMap());

      // 2. Create Members
      final membersData = [
        {'id': 'm1', 'name': 'أحمد محمود', 'phone': '01011111111', 'ratio': 1.0, 'amount': 5000.0, 'month': 3},
        {'id': 'm2', 'name': 'محمد عبد الله', 'phone': '01022222222', 'ratio': 0.5, 'amount': 2500.0, 'month': 7},
        {'id': 'm3', 'name': 'كريم حسن', 'phone': '01033333333', 'ratio': 0.5, 'amount': 2500.0, 'month': 4},
        {'id': 'm4', 'name': 'سارة إبراهيم', 'phone': '01044444444', 'ratio': 1.0, 'amount': 5000.0, 'month': 8},
        {'id': 'm5', 'name': 'محمود عبد العزيز', 'phone': '01055555555', 'ratio': 1.0, 'amount': 5000.0, 'month': 1},
        {'id': 'm6', 'name': 'منى الشاذلي', 'phone': '01066666666', 'ratio': 1.0, 'amount': 5000.0, 'month': 2},
        {'id': 'm7', 'name': 'ياسر جلال', 'phone': '01077777777', 'ratio': 1.0, 'amount': 5000.0, 'month': 5},
        {'id': 'm8', 'name': 'هاني شاكر', 'phone': '01088888888', 'ratio': 1.0, 'amount': 5000.0, 'month': 6},
        {'id': 'm9', 'name': 'عمرو دياب', 'phone': '01099999999', 'ratio': 1.0, 'amount': 5000.0, 'month': 9},
        {'id': 'm10', 'name': 'تامر حسني', 'phone': '01000000000', 'ratio': 1.0, 'amount': 5000.0, 'month': 10},
      ];

      for (final m in membersData) {
        await _firestore
            .collection('gameyas')
            .doc(gameyaId)
            .collection('members')
            .doc(m['id'] as String)
            .set({
          'id': m['id'],
          'gameyaId': gameyaId,
          'shareGroupId': 1,
          'memberName': m['name'],
          'phone': m['phone'],
          'shareRatio': m['ratio'],
          'installmentAmount': m['amount'],
          'payoutMonth': m['month'],
        });
      }

      // 3. Create Month 3 Installments
      final installmentsData = [
        {'id': 'inst_1', 'memberId': 'm1', 'status': InstallmentStatus.paid, 'amount': 5000.0},
        {'id': 'inst_2', 'memberId': 'm2', 'status': InstallmentStatus.paid, 'amount': 2500.0},
        {'id': 'inst_3', 'memberId': 'm3', 'status': InstallmentStatus.pending, 'amount': 2500.0},
        {'id': 'inst_4', 'memberId': 'm4', 'status': InstallmentStatus.review, 'amount': 5000.0},
        {'id': 'inst_5', 'memberId': 'm5', 'status': InstallmentStatus.paid, 'amount': 5000.0},
        {'id': 'inst_6', 'memberId': 'm6', 'status': InstallmentStatus.paid, 'amount': 5000.0},
        {'id': 'inst_7', 'memberId': 'm7', 'status': InstallmentStatus.paid, 'amount': 5000.0},
        {'id': 'inst_8', 'memberId': 'm8', 'status': InstallmentStatus.paid, 'amount': 5000.0},
        {'id': 'inst_9', 'memberId': 'm9', 'status': InstallmentStatus.paid, 'amount': 5000.0},
        {'id': 'inst_10', 'memberId': 'm10', 'status': InstallmentStatus.paid, 'amount': 5000.0},
      ];

      for (final inst in installmentsData) {
        final status = inst['status'] as InstallmentStatus;
        await _firestore
            .collection('gameyas')
            .doc(gameyaId)
            .collection('installments')
            .doc(inst['id'] as String)
            .set({
          'id': inst['id'],
          'gameyaId': gameyaId,
          'memberShareId': inst['memberId'],
          'monthNumber': 3,
          'amount': inst['amount'],
          'status': status.name,
          'dueDate': DateTime(2026, 3, 5).toIso8601String(),
          'paidAt': status == InstallmentStatus.paid ? DateTime.now().toIso8601String() : null,
        });
      }
    } catch (e) {
      // Catch permission-denied gracefully
    }
  }
}
