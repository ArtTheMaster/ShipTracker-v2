import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/support_chat_model.dart';

class SupportChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<SupportChatThread>> getCustomerThreads(String uid) {
    return _firestore
        .collection('support_chats')
        .where('customerUid', isEqualTo: uid)
        // FIXED: Removed the .orderBy query to bypass the Firestore Index requirement
        .snapshots()
        .map((snap) {
          final threads = snap.docs.map((doc) => SupportChatThread.fromFirestore(doc)).toList();
          // Sort descending in-memory instead
          threads.sort((a, b) {
            final aTime = a.lastMessageAt;
            final bTime = b.lastMessageAt;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });
          return threads;
        });
  }

  Stream<List<SupportChatThread>> getAdminThreads() {
    // Admin query uses only orderBy, so it does not trigger the index error
    return _firestore
        .collection('support_chats')
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => SupportChatThread.fromFirestore(doc)).toList());
  }

  Stream<List<ChatMessageModel>> getMessages(String threadId) {
    return _firestore
        .collection('support_chats')
        .doc(threadId)
        .collection('messages')
        .orderBy('createdAt', descending: false) // Oldest top, newest bottom
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ChatMessageModel.fromFirestore(doc)).toList());
  }

  Future<String> createThread({
    required String customerUid,
    required String customerName,
    required String subject,
    String? parcelId,
  }) async {
    final docRef = _firestore.collection('support_chats').doc();
    final thread = SupportChatThread(
      id: docRef.id,
      customerUid: customerUid,
      customerName: customerName,
      parcelId: parcelId,
      subject: subject,
      status: 'open',
      unreadForAdmin: 0,
      unreadForCustomer: 0,
      createdAt: DateTime.now(),
      lastMessageAt: DateTime.now(),
    );
    await docRef.set(thread.toFirestore());
    return docRef.id;
  }

  Future<void> sendMessage(String threadId, ChatMessageModel msg, bool isAdmin) async {
    final threadRef = _firestore.collection('support_chats').doc(threadId);
    final batch = _firestore.batch();
    
    final msgRef = threadRef.collection('messages').doc();
    batch.set(msgRef, msg.toFirestore());
    
    final updateData = {
      'lastMessage': msg.imageUrl != null ? '[Image attached]' : msg.text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'status': 'open', // New message reopens the thread automatically
    };
    
    if (isAdmin) {
      updateData['unreadForCustomer'] = FieldValue.increment(1);
    } else {
      updateData['unreadForAdmin'] = FieldValue.increment(1);
    }
    
    batch.update(threadRef, updateData);
    await batch.commit();
  }

  Future<void> markAsRead(String threadId, bool isAdmin) async {
    final field = isAdmin ? 'unreadForAdmin' : 'unreadForCustomer';
    await _firestore.collection('support_chats').doc(threadId).update({field: 0});
  }

  Future<void> updateThreadStatus(String threadId, String status) async {
    await _firestore.collection('support_chats').doc(threadId).update({'status': status});
  }
}