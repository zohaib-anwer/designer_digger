/// Firestore collection names for Designer Digger.
///
/// Must match collections in Firebase project `designerdigger-8549d`
/// (see android/app/google-services.json).
class FirestoreCollections {
  FirestoreCollections._();

  /// App user profiles (separate from any shared `users` collection).
  static const diggerUsers = 'digger_users';

  /// Catalog / cart data already on designerdigger-8549d.
  static const products = 'products';
  static const promotions = 'promotions';
  static const cartItems = 'cartitems';
  static const favourites = 'favourites';
  static const orders = 'orders';
}
