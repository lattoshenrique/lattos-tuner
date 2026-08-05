import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lattos_tuner/controllers/tuner_controller.dart';
import 'package:lattos_tuner/models/note.dart';
import 'package:lattos_tuner/models/tuning_preset.dart';
import 'package:lattos_tuner/views/theme.dart';
import 'package:lattos_tuner/views/widgets/string_chips.dart'
    show noteFrequencyLabel;

/// Criação e edição de presets customizados.
///
/// [existing] edita um preset em vez de criar; [base] pré-preenche o
/// formulário a partir de outro preset (duplicar).
class PresetEditorScreen extends StatefulWidget {
  const PresetEditorScreen({
    super.key,
    required this.controller,
    this.existing,
    this.base,
  });

  final TunerController controller;
  final TuningPreset? existing;
  final TuningPreset? base;

  @override
  State<PresetEditorScreen> createState() => _PresetEditorScreenState();
}

class _PresetEditorScreenState extends State<PresetEditorScreen> {
  late final TextEditingController _nameController;
  late Instrument _instrument;
  late List<int> _midiNotes;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final source = widget.existing ?? widget.base;
    _nameController = TextEditingController(
      text: widget.existing?.name ??
          (widget.base == null ? '' : '${widget.base!.name} (cópia)'),
    );
    _instrument = source?.instrument ?? Instrument.guitar;
    _midiNotes = (source?.notes ?? const ['E2', 'A2', 'D3', 'G3', 'B3', 'E4'])
        .map((n) => nameToMidi(n) ?? 40)
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dê um nome ao preset.')),
      );
      return;
    }
    if (_midiNotes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos uma corda.')),
      );
      return;
    }
    final preset = TuningPreset(
      id: widget.existing?.id ??
          'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      instrument: _instrument,
      notes: _midiNotes.map(midiToName).toList(),
    );
    await widget.controller.saveCustomPreset(preset);
    if (mounted) Navigator.of(context).pop();
  }

  void _shiftNote(int index, int semitones) {
    final next = (_midiNotes[index] + semitones).clamp(12, 108);
    if (next == _midiNotes[index]) return;
    HapticFeedback.selectionClick();
    setState(() => _midiNotes[index] = next);
  }

  void _addString() {
    HapticFeedback.lightImpact();
    setState(() {
      // Nova corda uma quarta acima da última (padrão em cordas graves).
      _midiNotes.add(
        _midiNotes.isEmpty ? 40 : (_midiNotes.last + 5).clamp(12, 108),
      );
    });
  }

  void _removeString(int index) {
    HapticFeedback.lightImpact();
    setState(() => _midiNotes.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        backgroundColor: AppColors.mint,
        foregroundColor: const Color(0xFF04291C),
        icon: const Icon(Icons.check_rounded),
        label: const Text(
          'Salvar',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(_isEditing ? 'Editar preset' : 'Novo preset'),
            backgroundColor: AppColors.background,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
            sliver: SliverList.list(
              children: [
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Nome do preset',
                    hintText: 'ex.: Minha afinação Drop B',
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'INSTRUMENTO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final instrument in Instrument.values)
                      ChoiceChip(
                        label: Text(instrument.label),
                        selected: _instrument == instrument,
                        showCheckmark: false,
                        selectedColor: AppColors.mint.withValues(alpha: 0.18),
                        backgroundColor: AppColors.surfaceBright,
                        side: BorderSide(
                          color: _instrument == instrument
                              ? AppColors.mint
                              : AppColors.outline,
                        ),
                        labelStyle: TextStyle(
                          color: _instrument == instrument
                              ? AppColors.mint
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (_) {
                          HapticFeedback.selectionClick();
                          setState(() => _instrument = instrument);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'CORDAS — DA MAIS GRAVE PARA A MAIS AGUDA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < _midiNotes.length; i++)
                  _StringRow(
                    key: ValueKey('string_$i'),
                    index: i,
                    midi: _midiNotes[i],
                    a4: widget.controller.a4,
                    onShift: (semitones) => _shiftNote(i, semitones),
                    onRemove:
                        _midiNotes.length > 1 ? () => _removeString(i) : null,
                  ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: _midiNotes.length >= 12 ? null : _addString,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.mint,
                    side: BorderSide(
                      color: AppColors.mint.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'Adicionar corda',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StringRow extends StatelessWidget {
  const _StringRow({
    super.key,
    required this.index,
    required this.midi,
    required this.a4,
    required this.onShift,
    this.onRemove,
  });

  final int index;
  final int midi;
  final double a4;
  final ValueChanged<int> onShift;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final name = midiToName(midi);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.surfaceBright,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => onShift(-1),
            tooltip: 'Meio tom abaixo',
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: Column(
                key: ValueKey(midi),
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    noteFrequencyLabel(name, a4: a4),
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => onShift(1),
            tooltip: 'Meio tom acima',
            icon: const Icon(
              Icons.keyboard_arrow_up_rounded,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onRemove,
            tooltip: 'Remover corda',
            icon: Icon(
              Icons.close_rounded,
              size: 20,
              color: onRemove == null
                  ? AppColors.outline
                  : AppColors.coral.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
