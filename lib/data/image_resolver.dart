import 'dart:io';
import 'package:flutter/widgets.dart';
import 'manifest_store.dart';
import 'assets_config.dart';

class ImageResolver {
  final ManifestStore store;
  final String imagesRootUrl;

  ImageResolver({required this.store, required this.imagesRootUrl});

  /// Ritorna un ImageProvider:
  /// - se il file locale esiste → FileImage
  /// - altrimenti → NetworkImage (raw GitHub)
  ImageProvider resolveProvider(String relativePath) {
    final file = store.fileForImagePath(relativePath);
    if (file.existsSync()) {
      return FileImage(file);
    }
    final url = imagesRootUrl + relativePath.replaceAll('\\', '/');
    return NetworkImage(url);
  }
}
