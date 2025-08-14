import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'manifest_models.dart';

class ManifestStore {
  final Directory root;           // es. <appSupport>/catalog
  final Directory imagesRootDir;  // es. <appSupport>/images
  final File manifestFile;        // manifest.json
  final File metaFile;            // manifest.meta.json
  final File assetIndexFile;      // asset_index.json

  ManifestStore._(this.root, this.imagesRootDir, this.manifestFile, this.metaFile, this.assetIndexFile);

  static Future<ManifestStore> open() async {
    final base = await getApplicationSupportDirectory();
    final catalogDir = Directory(p.join(base.path, 'catalog'));
    final imagesDir = Directory(p.join(base.path, 'images'));
    if (!await catalogDir.exists()) await catalogDir.create(recursive: true);
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
    return ManifestStore._(
      catalogDir,
      imagesDir,
      File(p.join(catalogDir.path, 'manifest.json')),
      File(p.join(catalogDir.path, 'manifest.meta.json')),
      File(p.join(catalogDir.path, 'asset_index.json')),
    );
  }

  Future<bool> hasLocalManifest() async => await manifestFile.exists();

  Future<void> saveManifest(BeyManifest m) async {
    await manifestFile.writeAsString(jsonEncode(m.toJson()));
  }

  Future<BeyManifest> readManifest() async {
    final txt = await manifestFile.readAsString();
    return BeyManifest.fromJson(jsonDecode(txt) as Map<String, dynamic>);
  }

  Future<void> saveMeta({required String version, String? etag, required String imagesRootUrl}) async {
    final j = {'version': version, if (etag != null) 'etag': etag, 'imagesRoot': imagesRootUrl};
    await metaFile.writeAsString(jsonEncode(j));
  }

  Future<Map<String, dynamic>?> readMeta() async {
    if (!await metaFile.exists()) return null;
    final txt = await metaFile.readAsString();
    return jsonDecode(txt) as Map<String, dynamic>;
  }

  Future<void> saveAssetIndex(Set<String> paths) async {
    await assetIndexFile.writeAsString(jsonEncode({'paths': paths.toList()}));
  }

  Future<Set<String>> readAssetIndex() async {
    if (!await assetIndexFile.exists()) return <String>{};
    final txt = await assetIndexFile.readAsString();
    final j = jsonDecode(txt) as Map<String, dynamic>;
    return (j['paths'] as List).cast<String>().toSet();
  }

  /// Restituisce il file locale per un path relativo del manifest (mantiene la stessa gerarchia).
  File fileForImagePath(String relativePath) {
    return File(p.join(imagesRootDir.path, p.normalize(relativePath)));
  }
}
