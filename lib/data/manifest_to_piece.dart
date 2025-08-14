import '../data/manifest_models.dart';
import '../models.dart'; // la tua classe Piece

/// Emula il vecchio CSV:
/// - categoria: "blade" | "rachet" | "bit" | "chip" | "assist_blade"
/// - tipoBey:  per Blade = "BX"/"UX"/"CX"
///             per Rachet = "STD"/"INTEGRATED"
///             per Bit = "STD"
///             per Chip/Assist = "CX"
/// - linkPng: URL assoluto (imagesRoot + path)
List<Piece> piecesFromManifest(BeyManifest m, String imagesRoot) {
  final out = <Piece>[];

  Piece mk({
    required String id,
    required String nome,
    required String categoria,
    required String tipoBey,
    required String relativePath,
  }) {
    final url = imagesRoot + relativePath; // es. media.githubusercontent.com/…/images/<path>
    // Adatta al costruttore reale della tua Piece se ha campi in più
    return Piece(
      id: id,
      nome: nome,
      categoria: categoria,
      tipoBey: tipoBey,
      linkPng: url,
    );
  }

  // Blade
  for (final p in m.parts.blade) {
    final system = (p.system ?? '').toUpperCase(); // BX/UX/CX
    out.add(mk(
      id: p.id,
      nome: p.name,
      categoria: 'blade',
      tipoBey: system,            // <- come nel CSV
      relativePath: p.path,
    ));
  }

  // Rachet
  for (final p in m.parts.rachet) {
    final type = ((p.type ?? '').toLowerCase() == 'integrated') ? 'INTEGRATED' : 'STD';
    out.add(mk(
      id: p.id,
      nome: p.name,
      categoria: 'rachet',
      tipoBey: type,              // <- STD / INTEGRATED come nel CSV
      relativePath: p.path,
    ));
  }

  // Bit
  for (final p in m.parts.bit) {
    out.add(mk(
      id: p.id,
      nome: p.name,
      categoria: 'bit',
      tipoBey: 'STD',             // <- nel CSV era STD
      relativePath: p.path,
    ));
  }

  // Chip (solo CX)
  for (final p in m.parts.chip) {
    out.add(mk(
      id: p.id,
      nome: p.name,
      categoria: 'chip',
      tipoBey: 'CX',              // <- come nel CSV
      relativePath: p.path,
    ));
  }

  // Assist Blade (solo CX)
  for (final p in m.parts.assist) {
    out.add(mk(
      id: p.id,
      nome: p.name,
      categoria: 'assist_blade',  // <- esattamente come nel CSV
      tipoBey: 'CX',
      relativePath: p.path,
    ));
  }

  return out;
}
