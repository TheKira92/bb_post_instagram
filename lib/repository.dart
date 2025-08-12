import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'models.dart';

class PiecesRepository {
  Future<List<Piece>> loadFromAssets(String path) async {
    final csvStr = await rootBundle.loadString(path);
    final raw = const CsvToListConverter().convert(csvStr, eol: '\n');

    List<Piece> out = [];
    for (final r in raw.skip(1)) {
      // id, nome, categoria, tipo_bey, link_png
      String id        = r[0].toString().trim();
      String nome      = r[1].toString().trim();
      String categoria = r[2].toString().trim();
      String tipoBey   = r[3].toString().trim();
      String link      = r[4].toString().trim().replaceAll('\r', '');

      out.add(Piece(
        id: id, nome: nome, categoria: categoria, tipoBey: tipoBey, linkPng: link,
      ));
    }
    return out;
  }
}

