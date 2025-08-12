import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repository.dart';
import 'app_state.dart';
import 'evento_page.dart';
import 'beyblade_page.dart';
import 'preview_page.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (_) => AppState(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BB Post Instagram',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const Shell(),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int idx = 0;

  @override
  void initState() {
    super.initState();
    _loadCsv();
  }

  Future<void> _loadCsv() async {
    final repo = PiecesRepository();
    final list = await repo.loadFromAssets('assets/components_test_placeholder.csv');
    if (!mounted) return;
    context.read<AppState>().setDataset(list);
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [EventoPage(), BeybladePage(), PreviewPage()];
    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer())),
        title: Text(['Evento','Beyblade','Anteprima'][idx]),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(children: const [
            DrawerHeader(child: Text('BB Post – Menu')),
            ListTile(leading: Icon(Icons.history), title: Text('Storico (soon)')),
            ListTile(leading: Icon(Icons.settings), title: Text('Impostazioni (soon)')),
            ListTile(leading: Icon(Icons.info_outline), title: Text('Info')),
          ]),
        ),
      ),
      body: pages[idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx, onDestinationSelected: (i) => setState(() => idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Evento'),
          NavigationDestination(icon: Icon(Icons.sports_martial_arts), label: 'Beyblade'),
          NavigationDestination(icon: Icon(Icons.image), label: 'Anteprima'),
        ],
      ),
    );
  }
}
