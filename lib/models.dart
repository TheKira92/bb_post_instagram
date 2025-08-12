class Piece {
  final String id;
  final String nome;
  final String categoria;   // blade | chip | assist_blade | rachet | bit
  final String tipoBey;     // BX | UX | CX | STD | INTEGRATED
  final String linkPng;

  const Piece({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.tipoBey,
    required this.linkPng,
  });

  factory Piece.fromCsv(List<String> r) => Piece(
        id: r[0],
        nome: r[1],
        categoria: r[2],
        tipoBey: r[3],
        linkPng: r[4],
      );
}

class EventData {
  String luogo = '';
  DateTime? data;
  String nomeEvento = '';
  String username = '';
  
  String? teamIconUrl; // opzionale
  int? posizione;      // opzionale
  // nuove proprietà
  String? playerAvatarPath; // file locale
  String? leagueLogoPath;   // file locale
  String bbxLogoAsset = 'assets/bbx_logo.png'; // asset fisso
}


class BeyConfig {
  Piece? blade;
  Piece? chip;
  Piece? assist;
  Piece? rachet;
  Piece? bit;

  BeyConfig copy() => BeyConfig()
    ..blade = blade
    ..chip = chip
    ..assist = assist
    ..rachet = rachet
    ..bit = bit;

  void clear() {
    blade = chip = assist = rachet = bit = null;
  }

  bool get isCX => blade?.tipoBey == 'CX';
  bool get rachetIntegrated => rachet?.tipoBey == 'INTEGRATED';
}
