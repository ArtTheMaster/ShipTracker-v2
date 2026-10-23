import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/parcel_model.dart';

class ParcelRepository {
  final FirebaseFirestore _firestore;

  ParcelRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _parcelsCol =>
      _firestore.collection(AppConstants.collectionParcels);

  // Real-time stream of all parcels (newest first)
  Stream<List<ParcelModel>> getParcelsStream() {
    return _parcelsCol
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ParcelModel.fromFirestore(doc)).toList());
  }

  // Real-time stream of a single parcel by ID (Fixes parcel_detail_screen.dart)
  Stream<ParcelModel?> getParcelByIdStream(String id) {
    return _parcelsCol.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ParcelModel.fromFirestore(doc);
    });
  }

  // Get single parcel by ID once
  Future<ParcelModel?> getParcelById(String id) async {
    final doc = await _parcelsCol.doc(id).get();
    if (!doc.exists) return null;
    return ParcelModel.fromFirestore(doc);
  }

  // Add new outbound parcel
  Future<String> addParcel(ParcelModel parcel) async {
    final ref = await _parcelsCol.add(parcel.toFirestore());
    return ref.id;
  }

  // Update status (Supports BOTH positional updateParcelStatus(id, status) and named arguments)
  Future<void> updateParcelStatus(
    String id,
    String status, {
    String? dispatchedById,
    String? dispatchedByName,
  }) async {
    final updateData = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (status == AppConstants.statusDispatched) {
      updateData['dispatchedAt'] = FieldValue.serverTimestamp();
      if (dispatchedById != null) updateData['dispatchedById'] = dispatchedById;
      if (dispatchedByName != null) updateData['dispatchedByName'] = dispatchedByName;
    }

    await _parcelsCol.doc(id).update(updateData);
  }
}