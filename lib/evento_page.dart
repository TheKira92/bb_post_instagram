import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class EventoPage extends StatelessWidget {
  const EventoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          TextField(decoration: const InputDecoration(labelText: 'Luogo'), onChanged: (v) => s.event.luogo = v),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(s.event.data == null ? 'Data evento' : 'Data: ${s.event.data!.toLocal().toString().split(' ').first}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context, firstDate: DateTime(now.year - 1), lastDate: DateTime(now.year + 2), initialDate: s.event.data ?? now,
              );
              if (picked != null) { s.event.data = picked; s.notifyListeners(); }
            },
          ),
          const SizedBox(height: 12),
          TextField(decoration: const InputDecoration(labelText: 'Nome evento'), onChanged: (v) => s.event.nomeEvento = v),
          const SizedBox(height: 12),
          TextField(decoration: const InputDecoration(labelText: 'Username (per grafica)'), onChanged: (v) => s.event.username = v),
          const SizedBox(height: 24),
          FilledButton.tonal(onPressed: s.resetEvento, child: const Text('Reset evento')),
        ],
      ),
    );
  }
}
