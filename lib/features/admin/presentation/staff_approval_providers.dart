import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/user_profile_model.dart';
import '../data/staff_approval_repository.dart';

final staffApprovalRepositoryProvider =
    Provider<StaffApprovalRepository>((ref) {
  return StaffApprovalRepository();
});

final pendingStaffProvider = StreamProvider<List<UserProfileModel>>((ref) {
  return ref.watch(staffApprovalRepositoryProvider).watchPendingStaff();
});

final pendingStaffCountProvider = Provider<int>((ref) {
  return ref.watch(pendingStaffProvider).value?.length ?? 0;
});
