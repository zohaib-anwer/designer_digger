import 'dart:io';

import 'package:designerdigger/Services/supabase_config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  SupabaseStorageService._();

  static final _client = Supabase.instance.client;
  static const _bucket = SupabaseConfig.mediaBucket;

  static String _fileName(XFile image, {String folder = 'products'}) {
    final original = image.name.isNotEmpty
        ? image.name
        : image.path.split(Platform.pathSeparator).last;
    final safe = original.replaceAll(RegExp(r'[^\w.\-]'), '_');
    return '$folder/${DateTime.now().millisecondsSinceEpoch}_$safe';
  }

  /// Uploads [image] to the public `media` bucket and returns its public URL.
  static Future<String> uploadImage(
    XFile image, {
    String folder = 'products',
  }) async {
    final path = _fileName(image, folder: folder);
    final file = File(image.path);

    await _client.storage.from(_bucket).upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from(_bucket).getPublicUrl(path);
  }

  static Future<XFile?> pickImage() async {
    return ImagePicker().pickImage(source: ImageSource.gallery);
  }
}
