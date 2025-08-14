import 'manifest_models.dart';

class CatalogIndex {
  final BeyManifest manifest;
  final Map<String, BeyPart> _byId = {};
  final Map<String, BeyPart> _byName = {};
  final Map<String, BeyPart> _byShort = {};
  final Map<String, BeyPart> _byAlias = {};

  CatalogIndex(this.manifest) {
    void indexPart(BeyPart p) {
      _byId[p.id.toLowerCase()] = p;
      _byName[p.name.toLowerCase()] = p;
      _byShort[p.short.toLowerCase()] = p;
      for (final a in (p.aliases ?? const [])) {
        _byAlias[a.toLowerCase()] = p;
      }
      for (final a in (p.aka ?? const [])) {
        _byAlias[a.toLowerCase()] = p;
      }
    }

    for (final p in manifest.parts.blade) indexPart(p);
    for (final p in manifest.parts.rachet) indexPart(p);
    for (final p in manifest.parts.bit) indexPart(p);
    for (final p in manifest.parts.chip) indexPart(p);
    for (final p in manifest.parts.assist) indexPart(p);
  }

  BeyPart? find(String key) {
    final k = key.toLowerCase();
    return _byId[k] ?? _byName[k] ?? _byShort[k] ?? _byAlias[k];
  }

  BeyPart? findBlade(String key) => manifest.parts.blade.firstWhere(
        (p) => p.id.toLowerCase() == key.toLowerCase() || p.name.toLowerCase() == key.toLowerCase() || p.short.toLowerCase() == key.toLowerCase() || (p.aliases ?? []).map((e) => e.toLowerCase()).contains(key.toLowerCase()),
        orElse: () => null as BeyPart,
      );
}
