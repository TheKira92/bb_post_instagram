import 'package:flutter/foundation.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  // dataset
  List<Piece> all = [];
  bool loaded = false;

  // evento
  final EventData event = EventData();

  // 3 beyblade
  final List<BeyConfig> bey = [BeyConfig(), BeyConfig(), BeyConfig()];
  int current = 0; // indice 0..2

  // dataset helpers
  List<Piece> get bladesBX => all.where((p) => p.categoria=='blade' && p.tipoBey=='BX').toList();
  List<Piece> get bladesUX => all.where((p) => p.categoria=='blade' && p.tipoBey=='UX').toList();
  List<Piece> get bladesCX => all.where((p) => p.categoria=='blade' && p.tipoBey=='CX').toList();
  List<Piece> get chips => all.where((p) => p.categoria=='chip').toList();
  List<Piece> get assists => all.where((p) => p.categoria=='assist_blade').toList();
  List<Piece> get rachetsStd => all.where((p) => p.categoria=='rachet' && p.tipoBey=='STD').toList();
  List<Piece> get rachetsIntegrated => all.where((p) => p.categoria=='rachet' && p.tipoBey=='INTEGRATED').toList();
  List<Piece> get bits => all.where((p) => p.categoria=='bit').toList();

  void setDataset(List<Piece> pieces) {
    all = pieces; loaded = true; notifyListeners();
  }

  // navigazione sotto-pagine (1/3)
  void goto(int i) { current = i.clamp(0, 2); notifyListeners(); }
  void next() => goto(current + 1);
  void prev() => goto(current - 1);

  // selezioni per slot corrente
  BeyConfig get slot => bey[current];

  void selectBlade(Piece? p) {
    slot.blade = p;
    if (!slot.isCX) { slot.chip = null; slot.assist = null; }
    notifyListeners();
  }

  void selectRachet(Piece? p) {
    slot.rachet = p;
    if (slot.rachetIntegrated) slot.bit = null;
    notifyListeners();
  }

  void selectChip(Piece? p){ slot.chip = p; notifyListeners(); }
  void selectAssist(Piece? p){ slot.assist = p; notifyListeners(); }
  void selectBit(Piece? p){ slot.bit = p; notifyListeners(); }

  void resetEvento(){
    event.luogo=''; event.data=null; event.nomeEvento=''; event.username=''; event.teamIconUrl=null; event.posizione=null;
    notifyListeners();
  }
  void resetAllBey(){ for (final b in bey) { b.clear(); } notifyListeners(); }
  void resetCurrent(){ slot.clear(); notifyListeners(); }
}
