import 'dart:math' as math;

/// Nomes das 12 notas da escala cromática, a partir de C.
const List<String> kNoteNames = [
  'C',
  'C#',
  'D',
  'D#',
  'E',
  'F',
  'F#',
  'G',
  'G#',
  'A',
  'A#',
  'B',
];

/// Frequência de referência padrão para o A4.
const double kDefaultA4 = 440.0;

/// Converte um número MIDI (possivelmente fracionário) em frequência (Hz).
double midiToFrequency(double midi, {double a4 = kDefaultA4}) =>
    a4 * math.pow(2.0, (midi - 69.0) / 12.0);

/// Converte uma frequência (Hz) em número MIDI fracionário.
double frequencyToMidi(double frequency, {double a4 = kDefaultA4}) =>
    69.0 + 12.0 * (math.log(frequency / a4) / math.ln2);

/// Diferença em cents entre [frequency] e [reference].
double centsBetween(double frequency, double reference) =>
    1200.0 * (math.log(frequency / reference) / math.ln2);

/// Nome científico da nota para um número MIDI, ex.: 36 -> "C2".
String midiToName(int midi) => '${kNoteNames[midi % 12]}${(midi ~/ 12) - 1}';

/// Interpreta nomes como "C2", "F#3" ou "Bb1". Retorna null se inválido.
int? nameToMidi(String name) {
  final match = RegExp(r'^([A-Ga-g])([#b]?)(-?\d+)$').firstMatch(name.trim());
  if (match == null) return null;
  const semitones = {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11};
  var semitone = semitones[match.group(1)!.toUpperCase()]!;
  if (match.group(2) == '#') semitone += 1;
  if (match.group(2) == 'b') semitone -= 1;
  final octave = int.parse(match.group(3)!);
  final midi = (octave + 1) * 12 + semitone;
  return (midi < 0 || midi > 127) ? null : midi;
}
