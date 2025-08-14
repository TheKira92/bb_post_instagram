import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'evento_page.dart';
import 'beyblade_page.dart';
import 'preview_page.dart';
import 'data/asset_sync.dart';
import 'data/catalog_index.dart';
import 'data/assets_config.dart';
import 'data/image_resolver.dart';
import 'data/manifest_to_piece.dart';
import 'data/manifest_store.dart';

late CatalogIndex catalogIndex;
late ImageResolver imageResolver;

Future<void> initCatalog() async {
  final sync = await AssetSync.create();
  await sync.run(onLog: (m) => debugPrint('[SYNC] $m'));

  final store = sync.store;
  final manifest = await store.readManifest();
  final imagesRoot = imagesRootFromManifestUrl(sync.remote.manifestUrl); // ⬅️ QUI

  catalogIndex = CatalogIndex(manifest);
  imageResolver = ImageResolver(store: store, imagesRootUrl: imagesRoot);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initCatalog();

  final store = await ManifestStore.open();
  final manifest = await store.readManifest();
  // final meta = await store.readMeta(); // opzionale

  final imagesRoot = imagesRootFromManifestUrl(kAssetsManifestUrl); // ⬅️ QUI

  final pieces = piecesFromManifest(manifest, imagesRoot);

  runApp(ChangeNotifierProvider(
    create: (_) {
      final s = AppState();
      s.setDataset(pieces);
      return s;
    },
    child: const MyApp(),
  ));
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
