const String kAssetsManifestUrl =
    'https://raw.githubusercontent.com/TheKira92/bey-assets/master/manifest/index.json';

// Costruisce SEMPRE la root immagini su media.githubusercontent.com per compatibilità LFS.
String imagesRootFromManifestUrl(String manifestUrl) {
  // Match: raw.githubusercontent.com/<user>/<repo>/<branch>/
  final re = RegExp(r'^https://raw\.githubusercontent\.com/([^/]+)/([^/]+)/([^/]+)/');
  final m = re.firstMatch(manifestUrl);
  if (m != null) {
    final user = m.group(1)!;
    final repo = m.group(2)!;
    final branch = m.group(3)!;
    // Root immagini su media + refs/heads/<branch>
    return 'https://media.githubusercontent.com/media/$user/$repo/refs/heads/$branch/images/';
  }

  // Se in futuro punti direttamente a github.com/.../raw/.../manifest/index.json,
  // puoi derivare user/repo/branch simile. Per ora fallback:
  const needle = '/manifest/index.json';
  final idx = manifestUrl.indexOf(needle);
  if (idx != -1) return manifestUrl.substring(0, idx) + '/images/';
  return manifestUrl;
}
