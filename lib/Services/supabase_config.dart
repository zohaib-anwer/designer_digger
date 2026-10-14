/// Shared Apps / Shared Storage project (storage only).
/// Auth & Firestore remain on Firebase.
class SupabaseConfig {
  static const String url = 'https://bvmpllkikwigvszmbbbn.supabase.co';

  /// Prefer publishable key; legacy anon JWT kept as fallback for older SDKs.
  static const String publishableKey =
      'sb_publishable_lK9h8jIS1rhSV-gvUnqrgg_q9te2HY5';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ2bXBsbGtpa3dpZ3Zzem1iYmJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE4ODQ3NDUsImV4cCI6MjEwNzQ2MDc0NX0.G8iQPnlBmw8GsgPKQGCiC37EWUaPHjq3ijQL-7MqeVk';

  /// Public bucket used for product / avatar / promotion images.
  static const String mediaBucket = 'media';
}
