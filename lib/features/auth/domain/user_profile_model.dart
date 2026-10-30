import '../../../core/constants/app_constants.dart';

class UserProfileModel {
  final String uid;
  final String email;
  final String fullName;
  final String role;
  final String status;
  final String? phoneNumber;
  final String? photoUrl;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectedBy;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfileModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.status = AppConstants.accountStatusActive,
    this.phoneNumber,
    this.photoUrl,
    this.approvedBy,
    this.approvedAt,
    this.rejectedBy,
    this.rejectedAt,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  // Role Checks
  bool get isAdmin =>
      role.toLowerCase() == 'admin' || role == AppConstants.roleAdmin;
  bool get isStaff =>
      role.toLowerCase() == 'staff' || role == AppConstants.roleStaff;

  // Approval status checks
  bool get isActive => status.toLowerCase() == AppConstants.accountStatusActive;
  bool get isPending =>
      status.toLowerCase() == AppConstants.accountStatusPending;
  bool get isRejected =>
      status.toLowerCase() == AppConstants.accountStatusRejected;

  // Convenience alias for displayName
  String get displayName => fullName;

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      fullName: (map['fullName'] ?? map['displayName'] ?? map['name'] ?? '')
          as String,
      role: map['role'] as String? ?? 'Staff',
      status: (map['status'] as String?)?.trim().toLowerCase() ??
          AppConstants.accountStatusActive,
      phoneNumber: map['phoneNumber'] as String?,
      photoUrl: map['photoUrl'] as String?,
      approvedBy: map['approvedBy'] as String?,
      approvedAt: _readDate(map['approvedAt']),
      rejectedBy: map['rejectedBy'] as String?,
      rejectedAt: _readDate(map['rejectedAt']),
      rejectionReason: map['rejectionReason'] as String?,
      createdAt: _readDate(map['createdAt']),
      updatedAt: _readDate(map['updatedAt']),
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'displayName': fullName,
      'role': role,
      'status': status,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (approvedBy != null) 'approvedBy': approvedBy,
      if (approvedAt != null) 'approvedAt': approvedAt,
      if (rejectedBy != null) 'rejectedBy': rejectedBy,
      if (rejectedAt != null) 'rejectedAt': rejectedAt,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  UserProfileModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? role,
    String? status,
    String? phoneNumber,
    String? photoUrl,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectedBy,
    DateTime? rejectedAt,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
}
