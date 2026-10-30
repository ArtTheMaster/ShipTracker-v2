import 'package:flutter_test/flutter_test.dart';
import 'package:gjandasher_shiptracker/core/constants/app_constants.dart';
import 'package:gjandasher_shiptracker/features/auth/domain/user_profile_model.dart';

void main() {
  group('UserProfileModel approval status', () {
    test('defaults legacy profiles to active', () {
      final profile = UserProfileModel.fromMap({
        'uid': 'legacy-1',
        'email': 'staff@example.com',
        'fullName': 'Legacy Staff',
        'role': 'staff',
      });

      expect(profile.status, AppConstants.accountStatusActive);
      expect(profile.isActive, isTrue);
      expect(profile.isPending, isFalse);
      expect(profile.isRejected, isFalse);
    });

    test('round-trips pending staff approval fields', () {
      final approvedAt = DateTime.utc(2026, 1, 2, 3, 4, 5);
      final profile = UserProfileModel(
        uid: 'staff-1',
        email: 'staff@example.com',
        fullName: 'Pending Staff',
        role: AppConstants.roleStaff,
        status: AppConstants.accountStatusPending,
        phoneNumber: '09171234567',
        approvedBy: 'admin-1',
        approvedAt: approvedAt,
        rejectionReason: 'Missing ID',
      );

      final restored = UserProfileModel.fromMap(profile.toMap());

      expect(restored.uid, 'staff-1');
      expect(restored.isStaff, isTrue);
      expect(restored.isPending, isTrue);
      expect(restored.phoneNumber, '09171234567');
      expect(restored.approvedBy, 'admin-1');
      expect(restored.approvedAt, approvedAt);
      expect(restored.rejectionReason, 'Missing ID');
    });

    test('normalizes status casing from Firestore', () {
      final profile = UserProfileModel.fromMap({
        'uid': 'staff-2',
        'email': 'staff@example.com',
        'fullName': 'Rejected Staff',
        'role': 'Staff',
        'status': 'REJECTED',
      });

      expect(profile.isRejected, isTrue);
      expect(profile.isPending, isFalse);
    });
  });
}
