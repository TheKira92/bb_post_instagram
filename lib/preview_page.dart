import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:saver_gallery/saver_gallery.dart';

import 'package:bb_post_instagram/app_state.dart';
import 'package:bb_post_instagram/models.dart';

class PreviewPage extends StatefulWidget {
  const PreviewPage({super.key});
  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  final _capKey = GlobalKey();

  Future<void> _download() async {
    final statuses = await [Permission.photos, Permission.storage].request();
    final granted = statuses.values.any((s) => s.isGranted);
    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Concedi i permessi per salvare l’immagine')),
      );
      return;
    }

    try {
      final boundary =
          _capKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final fileName = 'bb_post_${DateTime.now().millisecondsSinceEpoch}.png';
      final result = await SaverGallery.saveImage(
        bytes,
        quality: 100,
        extension: 'png',
        fileName: fileName,
        androidRelativePath: 'Pictures/BBPosts',
        skipIfExists: false,
      );

      final ok = result.isSuccess;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Immagine salvata' : 'Errore nel salvataggio')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Errore: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: RepaintBoundary(
              key: _capKey,
              child: _PreviewCanvas(state: s),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _download,
            child: const Text('Download 1080×1080'),
          ),
        ],
      ),
    );
  }
}

// ====================== CANVAS ======================

enum _Comp { chip, blade, assist, rachet, bit }

class _PreviewCanvas extends StatelessWidget {
  final AppState state;
  const _PreviewCanvas({required this.state});

  // --- abbreviazioni ---
  final Map<String, String> _assistAbbr = const {
    'Slash': 'S','Round': 'R','Bumper': 'B','Turn': 'T','Charge': 'C',
    'Jaggy': 'J','Assault': 'A','Wheel': 'Wh','Massive': 'M',
  };
  final Map<String, String> _bitAbbr = const {
    'High Needle':'HN','Needle':'N','Low Needle':'LN','Rush':'Rush','Low Rush':'LR',
    'Flat':'Flat','Low Flat':'LF','Ball':'Ball','Point':'Point','Orb':'Orb','Spike':'Spike',
  };
  String _firstWord(String s) => s.trim().split(RegExp(r'\s+')).first;
  String _abbrRachet(Piece? r) {
    if (r == null) return '—';
    final n = r.nome.trim();
    final m = RegExp(r'\b[0-9M]-[0-9]{2}\b').firstMatch(n);
    return m != null ? m.group(0)! : _firstWord(n);
  }
  String _abbrBit(Piece? b) {
    if (b == null) return '—';
    final n = b.nome.trim();
    if (_bitAbbr.containsKey(n)) return _bitAbbr[n]!;
    final fw = _firstWord(n);
    return fw.length <= 6 ? fw : fw.substring(0, 6);
  }
  String _abbrChip(Piece? c) => c == null ? '—' : _firstWord(c.nome);
  String _abbrAssist(Piece? a) {
    if (a == null) return '—';
    final n = _firstWord(a.nome);
    return _assistAbbr[n] ?? n[0].toUpperCase();
  }

  // --- stile outline tipo “meme” ---
  TextStyle _outline(double fs) => TextStyle(
        fontSize: fs,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        shadows: const [
          Shadow(blurRadius: 0, color: Colors.black, offset: Offset(0, 1)),
          Shadow(blurRadius: 0, color: Colors.black, offset: Offset(0, -1)),
          Shadow(blurRadius: 0, color: Colors.black, offset: Offset(1, 0)),
          Shadow(blurRadius: 0, color: Colors.black, offset: Offset(-1, 0)),
        ],
      );

  // --- helpers grafici ---
  TextStyle _hdr(double fs) =>
      TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: fs);
  TextStyle _txt(double fs) => TextStyle(color: Colors.white, fontSize: fs);

  Widget _label(String t, double fs) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(t, style: _txt(fs), textAlign: TextAlign.center),
      );

  Widget _placeholderBox({double size = 96}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(8),
        ),
      );

  Widget _imgNet(String rawUrl, double size) {
    final url = rawUrl.trim().replaceAll('\r', '');
    if (url.isEmpty) return _placeholderBox(size: size);
    final isSvg = url.toLowerCase().endsWith('.svg');
    final w = isSvg
        ? SvgPicture.network(url, width: size, height: size)
        : Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _placeholderBox(size: size),
          );
    return SizedBox.square(dimension: size, child: FittedBox(child: w));
  }

  Widget _imgFile(String? path, double size, {bool circle = false}) {
    if (path == null || path.isEmpty || !File(path).existsSync()) {
      return circle
          ? CircleAvatar(radius: size / 2, backgroundColor: Colors.white24)
          : Container(width: size, height: size, color: Colors.white24);
    }
    final img =
        Image.file(File(path), width: size, height: size, fit: BoxFit.cover);
    return circle
        ? CircleAvatar(radius: size / 2, backgroundImage: FileImage(File(path)))
        : ClipRRect(borderRadius: BorderRadius.circular(8), child: img);
  }

  // Slot overlay con testo
  Widget _slotOverlay({
    required String label,
    required String imageUrl,
    required double height,
    double pad = 6,
    double fsK = 0.16, // fattore per la dimensione font
  }) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: pad, horizontal: pad),
              child: _imgNet(imageUrl, height),
            ),
          ),
          Positioned(
            top: 4,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _outline(height * fsK),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Ordine dinamico componenti
  List<_Comp> _orderFor(BeyConfig b) {
    if (b.isCX) {
      return b.rachetIntegrated
          ? const [_Comp.chip, _Comp.blade, _Comp.assist, _Comp.rachet]
          : const [_Comp.chip, _Comp.blade, _Comp.assist, _Comp.rachet, _Comp.bit];
    } else {
      return b.rachetIntegrated
          ? const [_Comp.blade, _Comp.rachet]
          : const [_Comp.blade, _Comp.rachet, _Comp.bit];
    }
  }

  // Colonna dinamica (compressione per N=4/5)
  Widget _beyColumnDynamic(BeyConfig b, double colHeight) {
    final order = _orderFor(b);
    final N = order.length;

    // gap di base e tuning per N alti
    double gapBase = colHeight * 0.014;
    double gapV = gapBase * (3.5 / N);
    double totalGap = gapV * (N - 1);

    double slotH = (colHeight - totalGap) / N;
    double pad = slotH * 0.08;
    double fsK = 0.16;

    if (N >= 5) {
      gapV *= 0.8;
      totalGap = gapV * (N - 1);
      slotH = (colHeight - totalGap) / N;
      pad = slotH * 0.06;
      fsK = 0.13;
    } else if (N == 4) {
      gapV *= 0.9;
      totalGap = gapV * (N - 1);
      slotH = (colHeight - totalGap) / N;
      pad = slotH * 0.07;
      fsK = 0.14;
    }

    String labelOf(_Comp c) {
      switch (c) {
        case _Comp.blade:
          final n = b.blade?.nome ?? '—';
          final fw = _firstWord(n);
          return n.length <= 10 ? n : '$fw…';
        case _Comp.rachet:
          return _abbrRachet(b.rachet);
        case _Comp.bit:
          return _abbrBit(b.bit);
        case _Comp.chip:
          return _abbrChip(b.chip);
        case _Comp.assist:
          return _abbrAssist(b.assist);
      }
    }

    String urlOf(_Comp c) {
      switch (c) {
        case _Comp.blade:
          return b.blade?.linkPng ?? '';
        case _Comp.rachet:
          return b.rachet?.linkPng ?? '';
        case _Comp.bit:
          return b.bit?.linkPng ?? '';
        case _Comp.chip:
          return b.chip?.linkPng ?? '';
        case _Comp.assist:
          return b.assist?.linkPng ?? '';
      }
    }

    final children = <Widget>[];
    for (int i = 0; i < N; i++) {
      if (i > 0) children.add(SizedBox(height: gapV));
      final comp = order[i];
      children.add(_slotOverlay(
        label: labelOf(comp),
        imageUrl: urlOf(comp),
        height: slotH,
        pad: pad,
        fsK: fsK,
      ));
    }

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: children);
  }

  @override
  Widget build(BuildContext context) {
    final e = state.event;
    final b1 = state.bey[0], b2 = state.bey[1], b3 = state.bey[2];

    // adatta lo spazio: se almeno una colonna ha N=5, aumenta area componenti
    int maxN = [
      _orderFor(b1).length,
      _orderFor(b2).length,
      _orderFor(b3).length
    ].reduce((a, b) => a > b ? a : b);
    final headerFlex = (maxN >= 5) ? 1 : 2;
    final compsFlex = (maxN >= 5) ? 4 : 3;

    return Container(
      color: const Color(0xFF0D6E8B),
      padding: const EdgeInsets.all(14), // leggermente meno padding
      child: LayoutBuilder(
        builder: (context, c) {
          final h = c.maxHeight;
          final gap = h * 0.012;
          final titleFs = h * 0.028;
          final subFs = h * 0.017;
          final userFs = h * 0.020;

          return Column(
            children: [
              // HEADER
              Expanded(
                flex: headerFlex,
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 260),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  e.bbxLogoAsset,
                                  height: subFs * 1.6,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      Text('logo?', style: _txt(subFs)),
                                ),
                                SizedBox(height: gap * 0.6),
                                Text(
                                  e.nomeEvento.isEmpty ? 'TOURNAMENT' : e.nomeEvento,
                                  style: _hdr(titleFs),
                                  textAlign: TextAlign.center,
                                ),
                                if (e.data != null)
                                  Text(
                                    '${e.data!}'.split(' ').first,
                                    style: _txt(subFs),
                                    textAlign: TextAlign.center,
                                  ),
                                if (e.luogo.isNotEmpty)
                                  Text(e.luogo, style: _txt(subFs), textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _imgFile(e.playerAvatarPath, subFs * 2.2, circle: true),
                            SizedBox(height: gap * 0.6),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                e.username.isEmpty ? '@username' : e.username,
                                style: _hdr(userFs),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _imgFile(e.leagueLogoPath, subFs * 2.0),
                              SizedBox(height: gap * 0.6),
                              _label(e.posizione != null ? 'Pos: ${e.posizione}' : 'Top 3', subFs),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // COMPONENTI DINAMICI (2/3 o più dello spazio)
              Expanded(
                flex: compsFlex,
                child: LayoutBuilder(
                  builder: (_, cons) {
                    final colHeight = cons.maxHeight;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _beyColumnDynamic(b1, colHeight)),
                        Expanded(child: _beyColumnDynamic(b2, colHeight)),
                        Expanded(child: _beyColumnDynamic(b3, colHeight)),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
