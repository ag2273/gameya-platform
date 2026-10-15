import 'dart:async';
import '../../domain/models/gameya.dart';
import '../../domain/models/installment.dart';
import 'receipt_service.dart';

class PurgeResult {
  final int purgedReceiptCount;
  final int affectedGameyaCount;
  final List<Installment> updatedInstallments;
  final double estimatedFreedBytes;

  PurgeResult({
    required this.purgedReceiptCount,
    required this.affectedGameyaCount,
    required this.updatedInstallments,
    required this.estimatedFreedBytes,
  });
}

class StoragePurgeService {
  /// 5-Month post-completion photo retention policy (ADR-0009).
  static const int retentionMonths = 5;
  static const Duration retentionWindow = Duration(days: 150); // 5 months (30 days/month)

  /// Scans for completed Gameyas older than 5 months and purges their uploaded receipt photos
  /// from Firebase Storage, maintaining compliance with the 1 GB free tier.
  /// Preserves audit records (amount, dates, verifiers) in Firestore.
  static Future<PurgeResult> purgeExpiredReceipts({
    required List<Gameya> gameyas,
    required List<Installment> allInstallments,
    required ReceiptStorageProvider storageProvider,
    DateTime? currentDate,
  }) async {
    final now = currentDate ?? DateTime.now();

    // Identify expired completed Gameyas
    final expiredGameyaIds = <String>{};
    for (final gameya in gameyas) {
      if (gameya.status == GameyaStatus.completed && gameya.completedAt != null) {
        final expirationDate = gameya.completedAt!.add(retentionWindow);
        if (now.isAfter(expirationDate)) {
          expiredGameyaIds.add(gameya.id);
        }
      }
    }

    if (expiredGameyaIds.isEmpty) {
      return PurgeResult(
        purgedReceiptCount: 0,
        affectedGameyaCount: 0,
        updatedInstallments: allInstallments,
        estimatedFreedBytes: 0,
      );
    }

    int purgedCount = 0;
    final updatedList = <Installment>[];

    for (final inst in allInstallments) {
      if (expiredGameyaIds.contains(inst.gameyaId) && inst.receiptUrl != null) {
        // Delete image file from Firebase Storage
        await storageProvider.deleteReceipt(inst.receiptUrl!);
        purgedCount++;

        // Clear receiptUrl while preserving all audit transaction records
        updatedList.add(inst.copyWith(clearReceiptUrl: true));
      } else {
        updatedList.add(inst);
      }
    }

    // Estimated ~120KB per compressed receipt freed
    final freedBytes = purgedCount * 120.0 * 1024.0;

    return PurgeResult(
      purgedReceiptCount: purgedCount,
      affectedGameyaCount: expiredGameyaIds.length,
      updatedInstallments: updatedList,
      estimatedFreedBytes: freedBytes,
    );
  }
}
