import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'models.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BeybladePage extends StatelessWidget {
  const BeybladePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (!s.loaded) return const Center(child: CircularProgressIndicator());
    final slot = s.slot;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Reset tutti in alto
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: s.resetAllBey,
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Reset tutti'),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                const Text('Blade'),
                const SizedBox(height: 8),
                _PieceDropdown(
                  pieces: [...s.bladesBX, ...s.bladesUX, ...s.bladesCX],
                  value: slot.blade,
                  onChanged: s.selectBlade,
                ),
                if (slot.isCX) ...[
                  const SizedBox(height: 16),
                  const Text('Chip (CX)'),
                  const SizedBox(height: 8),
                  _PieceDropdown(pieces: s.chips, value: slot.chip, onChanged: s.selectChip),
                  const SizedBox(height: 16),
                  const Text('Assist Blade (CX)'),
                  const SizedBox(height: 8),
                  _PieceDropdown(pieces: s.assists, value: slot.assist, onChanged: s.selectAssist),
                ],
                const SizedBox(height: 16),
                const Text('Rachet'),
                const SizedBox(height: 8),
                _PieceDropdown(
                  pieces: [...s.rachetsIntegrated, ...s.rachetsStd],
                  value: slot.rachet,
                  onChanged: s.selectRachet,
                ),
                if (!slot.rachetIntegrated && s.bits.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Bit'),
                  const SizedBox(height: 8),
                  _PieceDropdown(pieces: s.bits, value: slot.bit, onChanged: s.selectBit),
                ],
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: s.resetCurrent,
                  child: const Text('Pulisci questo Beyblade'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Footer 1 di 3 Beyblades
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: s.prev, icon: const Icon(Icons.chevron_left)),
              Text('${s.current + 1} di 3 Beyblades'),
              IconButton(onPressed: s.next, icon: const Icon(Icons.chevron_right)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PieceDropdown extends StatelessWidget {
  final List<Piece> pieces;
  final Piece? value;
  final ValueChanged<Piece?> onChanged;
  const _PieceDropdown({super.key, required this.pieces, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Piece>(
      value: value,
      isExpanded: true,
      items: pieces.map((p) {
        final isSvg = p.linkPng.toLowerCase().endsWith('.svg');
        final thumb = SizedBox(
          width: 32, height: 32,
          child: isSvg ? SvgPicture.network(p.linkPng) : Image.network(p.linkPng),
        );
        return DropdownMenuItem(value: p, child: Row(children: [
          thumb, const SizedBox(width: 12), Expanded(child: Text('${p.nome}  •  ${p.categoria.toUpperCase()}/${p.tipoBey}')),
        ]));
      }).toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
  }
}
