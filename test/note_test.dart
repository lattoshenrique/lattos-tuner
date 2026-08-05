import 'package:flutter_test/flutter_test.dart';
import 'package:lattos_tuner/models/note.dart';

void main() {
  group('midiToFrequency', () {
    test('A4 (midi 69) é a referência', () {
      expect(midiToFrequency(69), closeTo(440.0, 1e-9));
      expect(midiToFrequency(69, a4: 442), closeTo(442.0, 1e-9));
    });

    test('uma oitava dobra a frequência', () {
      expect(midiToFrequency(81), closeTo(880.0, 1e-6));
      expect(midiToFrequency(57), closeTo(220.0, 1e-6));
    });

    test('notas de referência de afinação', () {
      expect(midiToFrequency(40), closeTo(82.407, 0.001)); // E2
      expect(midiToFrequency(36), closeTo(65.406, 0.001)); // C2 (Drop C)
      expect(midiToFrequency(28), closeTo(41.203, 0.001)); // E1 (baixo)
    });
  });

  group('frequencyToMidi', () {
    test('é inversa de midiToFrequency', () {
      for (final midi in [28, 40, 45, 50, 55, 59, 64, 69, 81]) {
        expect(
          frequencyToMidi(midiToFrequency(midi.toDouble())),
          closeTo(midi.toDouble(), 1e-9),
        );
      }
    });
  });

  group('centsBetween', () {
    test('mesma frequência é zero', () {
      expect(centsBetween(440, 440), closeTo(0, 1e-9));
    });

    test('um semitom são 100 cents', () {
      expect(centsBetween(midiToFrequency(70), 440), closeTo(100, 1e-6));
      expect(centsBetween(midiToFrequency(68), 440), closeTo(-100, 1e-6));
    });
  });

  group('midiToName', () {
    test('nomes científicos', () {
      expect(midiToName(60), 'C4');
      expect(midiToName(69), 'A4');
      expect(midiToName(36), 'C2');
      expect(midiToName(37), 'C#2');
      expect(midiToName(23), 'B0');
    });
  });

  group('nameToMidi', () {
    test('interpreta sustenidos, bemóis e caixa baixa', () {
      expect(nameToMidi('C4'), 60);
      expect(nameToMidi('A4'), 69);
      expect(nameToMidi('C#2'), 37);
      expect(nameToMidi('Db2'), 37);
      expect(nameToMidi('e2'), 40);
      expect(nameToMidi('B0'), 23);
    });

    test('rejeita entradas inválidas', () {
      expect(nameToMidi(''), isNull);
      expect(nameToMidi('H2'), isNull);
      expect(nameToMidi('C'), isNull);
      expect(nameToMidi('C##2'), isNull);
      expect(nameToMidi('X#9'), isNull);
    });

    test('é inversa de midiToName', () {
      for (var midi = 12; midi <= 108; midi++) {
        expect(nameToMidi(midiToName(midi)), midi);
      }
    });
  });
}
