import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:designerdigger/Services/firestore_collections.dart';

class UserProfileService {
  UserProfileService._();

  static DocumentReference<Map<String, dynamic>> doc(String uid) {
    return FirebaseFirestore.instance
        .collection(FirestoreCollections.diggerUsers)
        .doc(uid);
  }

  /// Writes profile and confirms it exists on the server (not only local cache).
  static Future<void> saveProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    final ref = doc(uid);
    await ref.set(data, SetOptions(merge: true));

    // Flush local queue; fails if server rules reject the write.
    await FirebaseFirestore.instance.waitForPendingWrites();

    final verified = await ref.get(const GetOptions(source: Source.server));
    if (!verified.exists) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message:
            'Profile was not saved to digger_users. Check Firestore rules.',
      );
    }
  }
}
