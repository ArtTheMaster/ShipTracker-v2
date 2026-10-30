import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/email_service.dart';
import '../../auth/domain/user_profile_model.dart';

class StaffApprovalResult {
  final bool emailSent;
  final String? emailError;

  const StaffApprovalResult({
    required this.emailSent,
    this.emailError,
  });
}

/// Admin/owner-only operations for reviewing staff registrations.
class StaffApprovalRepository {
  final FirebaseFirestore _firestore;
  final EmailService _emailService;

  StaffApprovalRepository({
    FirebaseFirestore? firestore,
    EmailService? emailService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _emailService = emailService ?? EmailService();

  /// Watches every staff profile and filters pending registrations locally.
  ///
  /// Filtering in memory avoids a composite index and also tolerates older
  /// profiles that stored the role as "Staff" instead of "staff".
  Stream<List<UserProfileModel>> watchPendingStaff() {
    return _firestore
        .collection(AppConstants.collectionUsers)
        .where('role', whereIn: const ['staff', 'Staff'])
        .snapshots()
        .map((snapshot) {
          final pending = snapshot.docs
              .map((doc) => UserProfileModel.fromMap(doc.data()))
              .where((profile) => profile.isStaff && profile.isPending)
              .toList();

          pending.sort((a, b) {
            final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return aDate.compareTo(bDate);
          });

          return pending;
        });
  }

  /// Marks a staff account active and sends the approval email.
  ///
  /// The Firestore update is the source of truth; a failed email does not
  /// roll back the approval. The caller receives [StaffApprovalResult] so it
  /// can warn the admin to resend or check the worker configuration.
  Future<StaffApprovalResult> approveStaff({
    required UserProfileModel staff,
    required String adminUid,
  }) async {
    await _firestore
        .collection(AppConstants.collectionUsers)
        .doc(staff.uid)
        .update({
      'status': AppConstants.accountStatusActive,
      'approvedBy': adminUid,
      'approvedAt': FieldValue.serverTimestamp(),
      'rejectionReason': FieldValue.delete(),
      'rejectedBy': FieldValue.delete(),
      'rejectedAt': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    try {
      await _emailService.sendStaffApproved(
        to: staff.email,
        name: staff.fullName,
      );
      return const StaffApprovalResult(emailSent: true);
    } catch (e) {
      return StaffApprovalResult(
        emailSent: false,
        emailError: e.toString(),
      );
    }
  }

  Future<void> rejectStaff({
    required UserProfileModel staff,
    required String adminUid,
    String? reason,
  }) async {
    final trimmedReason = reason?.trim();

    await _firestore
        .collection(AppConstants.collectionUsers)
        .doc(staff.uid)
        .update({
      'status': AppConstants.accountStatusRejected,
      'approvedBy': FieldValue.delete(),
      'approvedAt': FieldValue.delete(),
      'rejectedBy': adminUid,
      'rejectedAt': FieldValue.serverTimestamp(),
      'rejectionReason': (trimmedReason == null || trimmedReason.isEmpty)
          ? FieldValue.delete()
          : trimmedReason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Retries the approval email without changing the account status. Useful
  /// when the first attempt failed because the email worker was misconfigured.
  Future<StaffApprovalResult> resendApprovalEmail(
    UserProfileModel staff,
  ) async {
    try {
      await _emailService.sendStaffApproved(
        to: staff.email,
        name: staff.fullName,
      );
      return const StaffApprovalResult(emailSent: true);
    } catch (e) {
      return StaffApprovalResult(emailSent: false, emailError: e.toString());
    }
  }
}
