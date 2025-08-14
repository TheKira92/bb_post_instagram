class BeyManifest {
  final int schema;
  final String version;
  final Parts parts;
  BeyManifest({required this.schema, required this.version, required this.parts});

  factory BeyManifest.fromJson(Map<String, dynamic> j) => BeyManifest(
        schema: j['schema'] as int,
        version: j['version'] as String,
        parts: Parts.fromJson(j['parts'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'schema': schema,
        'version': version,
        'parts': parts.toJson(),
      };
}

class Parts {
  final List<BeyPart> blade;
  final List<BeyPart> rachet;
  final List<BeyPart> bit;
  final List<BeyPart> chip;
  final List<BeyPart> assist;

  Parts({
    required this.blade,
    required this.rachet,
    required this.bit,
    required this.chip,
    required this.assist,
  });

  factory Parts.fromJson(Map<String, dynamic> j) => Parts(
        blade: (j['blade'] as List).map((e) => BeyPart.fromJson(e)).toList(),
        rachet: (j['rachet'] as List).map((e) => BeyPart.fromJson(e)).toList(),
        bit: (j['bit'] as List).map((e) => BeyPart.fromJson(e)).toList(),
        chip: (j['chip'] as List).map((e) => BeyPart.fromJson(e)).toList(),
        assist: (j['assist'] as List).map((e) => BeyPart.fromJson(e)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'blade': blade.map((e) => e.toJson()).toList(),
        'rachet': rachet.map((e) => e.toJson()).toList(),
        'bit': bit.map((e) => e.toJson()).toList(),
        'chip': chip.map((e) => e.toJson()).toList(),
        'assist': assist.map((e) => e.toJson()).toList(),
      };

  /// Ritorna la lista di tutti i path immagine (relativi) presenti nel manifest.
  List<String> allPaths() => [
        ...blade.map((e) => e.path),
        ...rachet.map((e) => e.path),
        ...bit.map((e) => e.path),
        ...chip.map((e) => e.path),
        ...assist.map((e) => e.path),
      ];
}

class BeyPart {
  final String id;
  final String name;
  final String short;
  final String path;

  // opzionali / categoria-specifici
  final String? system;   // BX/UX/CX (blade)
  final String? config;   // integrated/standard (blade)
  final String? category; // canon/collab/xover (blade)
  final String? type;     // standard/integrated (rachet)
  final List<String>? aliases;
  final List<String>? aka;

  BeyPart({
    required this.id,
    required this.name,
    required this.short,
    required this.path,
    this.system,
    this.config,
    this.category,
    this.type,
    this.aliases,
    this.aka,
  });

  factory BeyPart.fromJson(Map<String, dynamic> j) => BeyPart(
        id: j['id'],
        name: j['name'],
        short: j['short'],
        path: j['path'],
        system: j['system'],
        config: j['config'],
        category: j['category'],
        type: j['type'],
        aliases: (j['aliases'] as List?)?.cast<String>(),
        aka: (j['aka'] as List?)?.cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'short': short,
        'path': path,
        if (system != null) 'system': system,
        if (config != null) 'config': config,
        if (category != null) 'category': category,
        if (type != null) 'type': type,
        if (aliases != null) 'aliases': aliases,
        if (aka != null) 'aka': aka,
      };
}
