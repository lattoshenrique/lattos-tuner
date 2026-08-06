import 'package:flutter_test/flutter_test.dart';
import 'package:lattos_tuner/controllers/tuner_controller.dart';
import 'package:lattos_tuner/models/tuner_reading.dart';
import 'package:lattos_tuner/services/haptic_guide.dart';

TunerReading readingAt(double cents, {int targetMidi = 40}) {
  final tolerance = cents.abs();
  return TunerReading(
    frequency: 100,
    targetMidi: targetMidi,
    cents: cents,
    status: tolerance <= TunerController.inTuneCents
        ? TuningStatus.inTune
        : cents < 0
        ? (tolerance >= TunerController.slightlyOffCents
              ? TuningStatus.tooLow
              : TuningStatus.slightlyLow)
        : (tolerance >= TunerController.slightlyOffCents
              ? TuningStatus.tooHigh
              : TuningStatus.slightlyHigh),
    stringIndex: 0,
  );
}

/// Roda [duration] de guia em passos de 40 ms (o ritmo da tela) e devolve os
/// pulsos disparados.
List<HapticPulse> run(
  HapticGuide guide,
  TunerReading? reading, {
  Duration duration = const Duration(seconds: 2),
  Duration start = Duration.zero,
  bool running = true,
  bool enabled = true,
}) {
  final pulses = <HapticPulse>[];
  for (
    var elapsed = start;
    elapsed < start + duration;
    elapsed += const Duration(milliseconds: 40)
  ) {
    final pulse = guide.evaluate(
      reading: reading,
      running: running,
      enabled: enabled,
      now: elapsed,
    );
    if (pulse != null) pulses.add(pulse);
  }
  return pulses;
}

void main() {
  test('quanto mais perto da nota, mais rápidos os pulsos', () async {
    final far = run(HapticGuide(), readingAt(45));
    final middle = run(HapticGuide(), readingAt(20));
    final near = run(HapticGuide(), readingAt(8));

    expect(far.length, lessThan(middle.length));
    expect(middle.length, lessThan(near.length));
    // Em 2 s: ~3 pulsos bem longe, mais de uma dúzia na borda da zona.
    expect(far.length, greaterThanOrEqualTo(2));
    expect(near.length, greaterThan(12));
  });

  test('quanto mais longe, mais forte o pulso', () {
    expect(run(HapticGuide(), readingAt(40)).first, HapticPulse.heavy);
    expect(run(HapticGuide(), readingAt(-40)).first, HapticPulse.heavy);
    expect(run(HapticGuide(), readingAt(18)).first, HapticPulse.medium);
    expect(run(HapticGuide(), readingAt(8)).first, HapticPulse.light);
  });

  test('afinou: confirma uma vez e depois silencia', () {
    final guide = HapticGuide();
    final pulses = run(guide, readingAt(2));

    expect(pulses, [HapticPulse.arrival]);

    // Sair e voltar à zona confirma de novo.
    run(guide, readingAt(20), start: const Duration(seconds: 2));
    final again = run(guide, readingAt(1), start: const Duration(seconds: 4));
    expect(again, [HapticPulse.arrival]);
  });

  test('outra corda recomeça a contagem e confirma de novo', () {
    final guide = HapticGuide();
    expect(run(guide, readingAt(2)), [HapticPulse.arrival]);

    final other = run(
      guide,
      readingAt(2, targetMidi: 45),
      start: const Duration(seconds: 2),
    );
    expect(other, [HapticPulse.arrival]);
  });

  test('não vibra sem leitura, com microfone parado ou desligado', () {
    expect(run(HapticGuide(), null), isEmpty);
    expect(run(HapticGuide(), readingAt(30), running: false), isEmpty);
    expect(run(HapticGuide(), readingAt(30), enabled: false), isEmpty);
  });

  test('silêncio no meio da afinação não deixa pulso pendurado', () {
    final guide = HapticGuide();
    run(guide, readingAt(30));
    // Microfone para: o guia esquece a nota e a próxima leitura recomeça.
    expect(
      run(guide, null, start: const Duration(seconds: 2)),
      isEmpty,
    );
    final resumed = run(
      guide,
      readingAt(2),
      start: const Duration(seconds: 4),
      duration: const Duration(milliseconds: 80),
    );
    expect(resumed, [HapticPulse.arrival]);
  });
}
