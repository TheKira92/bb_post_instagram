import 'dart:convert';
import 'package:http/http.dart' as http;
import 'manifest_models.dart';

class RemoteManifestResult {
  final BeyManifest manifest;
  final String? etag;
  RemoteManifestResult(this.manifest, this.etag);
}

// ManifestNotModifiedException: eccezione pubblica
class ManifestNotModifiedException implements Exception {
  const ManifestNotModifiedException();
}

class ManifestRemote {
  final String manifestUrl;
  ManifestRemote(this.manifestUrl);

  Future<RemoteManifestResult> fetch({String? ifNoneMatch}) async {
    final headers = <String, String>{};
    if (ifNoneMatch != null && ifNoneMatch.isNotEmpty) {
      headers['If-None-Match'] = ifNoneMatch;
    }

    final resp = await http.get(Uri.parse(manifestUrl), headers: headers);

    if (resp.statusCode == 304) {
      // manifest invariato
      throw const ManifestNotModifiedException();
    }
    if (resp.statusCode != 200) {
      throw Exception('Manifest HTTP ${resp.statusCode}');
    }

    final etag = resp.headers['etag'];
    final jsonMap = jsonDecode(resp.body) as Map<String, dynamic>;
    final manifest = BeyManifest.fromJson(jsonMap);
    return RemoteManifestResult(manifest, etag);
  }
}
