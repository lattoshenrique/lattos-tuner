/// Tipo de instrumento de um preset, usado para filtro e organização.
/// O rótulo exibido é localizado na camada de views (`InstrumentL10n`).
enum Instrument {
  guitar,
  bass,
  ukulele,
  cavaquinho,
  other;

  static Instrument fromName(String? name) => Instrument.values.firstWhere(
    (value) => value.name == name,
    orElse: () => Instrument.other,
  );
}

/// Um preset de afinação: uma lista ordenada de notas (da mais grave para a
/// mais aguda), com nome e instrumento.
class TuningPreset {
  const TuningPreset({
    required this.id,
    required this.name,
    required this.instrument,
    required this.notes,
    this.isBuiltIn = false,
  });

  factory TuningPreset.fromJson(Map<String, dynamic> json) => TuningPreset(
    id: json['id'] as String,
    name: json['name'] as String,
    instrument: Instrument.fromName(json['instrument'] as String?),
    notes: (json['notes'] as List<dynamic>).cast<String>(),
  );

  final String id;
  final String name;
  final Instrument instrument;

  /// Notas das cordas em notação científica (ex.: "C2"), da grave à aguda.
  final List<String> notes;

  final bool isBuiltIn;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'instrument': instrument.name,
    'notes': notes,
  };

  TuningPreset copyWith({
    String? id,
    String? name,
    Instrument? instrument,
    List<String>? notes,
    bool? isBuiltIn,
  }) => TuningPreset(
    id: id ?? this.id,
    name: name ?? this.name,
    instrument: instrument ?? this.instrument,
    notes: notes ?? List.of(this.notes),
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
  );
}
