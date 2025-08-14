import 'dart:async';
import 'package:http/http.dart' as http;

import 'assets_config.dart';
import 'manifest_remote.dart';
import 'manifest_store.dart';

class AssetSync {
  final ManifestStore store;
  final ManifestRemote remote;
  final http.Client _client;

  AssetSync._(this.store, this.remote, this._client);

  static Future<AssetSync> create() async {
    final store = await ManifestStore.open();
    final remote = ManifestRemote(kAssetsManifestUrl);
    return AssetSync._(store, remote, http.Client());
  }

  Future<void> run({void Function(String msg)? onLog, int concurrency = 6}) async {
    final log = onLog ?? (_) {};
    final hasLocal = await store.hasLocalManifest();

    if (!hasLocal) {
      // Primo avvio: scarico manifest + tutte le immagini
      log('No local manifest: downloading full catalog…');
      final res = await remote.fetch();
      await store.saveManifest(res.manifest);
      final imagesRoot = imagesRootFromManifestUrl(remote.manifestUrl);
      await store.saveMeta(version: res.manifest.version, etag: res.etag, imagesRootUrl: imagesRoot);

      final allPaths = res.manifest.parts.allPaths().toSet();
      await _downloadMany(allPaths, imagesRoot, concurrency: concurrency, onLog: onLog);
      await store.saveAssetIndex(allPaths);
      log('Full catalog sync completed.');
      return;
    }

    // C'è un manifest locale: controlla remoto via ETag (se presente) o via versione
    final meta = await store.readMeta();
    final localEtag = meta?['etag'] as String?;
    final localVersion = meta?['version'] as String?;
    final imagesRoot = meta?['imagesRoot'] as String? ?? imagesRootFromManifestUrl(remote.manifestUrl);

    try {
      final res = await remote.fetch(ifNoneMatch: localEtag);
      // Se arriviamo qui, c'è un manifest nuovo (status 200)
      final newManifest = res.manifest;
      if (localVersion != null && newManifest.version == localVersion) {
        // ETag non usabile ma versione identica → niente da fare
        return;
      }
      await store.saveManifest(newManifest);
      await store.saveMeta(version: newManifest.version, etag: res.etag, imagesRootUrl: imagesRoot);

      final remotePaths = newManifest.parts.allPaths().toSet();
      final localPaths = await store.readAssetIndex();

      // scarica SOLO i path nuovi
      final toDownload = remotePaths.difference(localPaths);
      if (toDownload.isNotEmpty) {
        log('Found ${toDownload.length} new assets → downloading…');
        await _downloadMany(toDownload, imagesRoot, concurrency: concurrency, onLog: onLog);
      }

      // opzionale: rimuovi quelli non più presenti (qui li teniamo)
      final updatedIndex = localPaths.union(remotePaths);
      await store.saveAssetIndex(updatedIndex);
      log('Incremental sync completed (${toDownload.length} new files).');
    } on ManifestNotModifiedException {
      // 304 → nessun cambiamento
      // log('Manifest not modified (304).');
      return;
    }
  }

  Future<void> _downloadMany(Set<String> paths, String imagesRoot,
      {int concurrency = 6, void Function(String msg)? onLog}) async {
    final log = onLog ?? (_) {};
    if (paths.isEmpty) return;
    final list = paths.toList();
    for (int i = 0; i < list.length; i += concurrency) {
      final chunk = list.sublist(i, i + concurrency > list.length ? list.length : i + concurrency);
      await Future.wait(chunk.map((rel) => _downloadOne(rel, imagesRoot).catchError((e, st) {
            log('Download failed: $rel → $e');
          })));
    }
  }

  Future<void> _downloadOne(String relPath, String imagesRoot) async {
    final file = store.fileForImagePath(relPath);
    if (await file.exists()) return; // già presente

    // crea parent dirs
    await file.parent.create(recursive: true);

    final url = imagesRoot + relPath.replaceAll('\\', '/');
    final resp = await _client.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode} for $url');
    }
    await file.writeAsBytes(resp.bodyBytes);
  }
}
