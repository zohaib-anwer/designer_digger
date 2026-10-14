import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:designerdigger/Services/firestore_collections.dart';
import 'package:designerdigger/main.dart';

class AdminService {
  AdminService._();

  static String? get _uid => box.read('uid')?.toString();

  static Stream<bool> isAdminStream() {
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      return Stream.value(false);
    }

    return FirebaseFirestore.instance
        .collection(FirestoreCollections.diggerUsers)
        .doc(uid)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      return data != null && data['isAdmin'] == true;
    });
  }

  static Future<bool> isAdmin() async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return false;

    final doc = await FirebaseFirestore.instance
        .collection(FirestoreCollections.diggerUsers)
        .doc(uid)
        .get();
    final data = doc.data();
    return data != null && data['isAdmin'] == true;
  }
}
