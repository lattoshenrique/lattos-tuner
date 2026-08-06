import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lattos_tuner/controllers/tuner_controller.dart';
import 'package:lattos_tuner/models/tuning_preset.dart';
import 'package:lattos_tuner/views/l10n.dart';
import 'package:lattos_tuner/views/screens/preset_editor_screen.dart';
import 'package:lattos_tuner/views/theme.dart';
import 'package:lattos_tuner/views/widgets/liquid_glass.dart';

/// Lista de afinações: embutidas e criadas pelo usuário.
class PresetsScreen extends StatefulWidget {
  const PresetsScreen({super.key, required this.controller});

  final TunerController controller;

  @override
  State<PresetsScreen> createState() => _PresetsScreenState();
}

class _PresetsScreenState extends State<PresetsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  /// Filtro por instrumento; null exibe todos.
  Instrument? _filter;

  TunerController get controller => widget.controller;

  List<TuningPreset> _applyFilter(List<TuningPreset> presets) => _filter == null
      ? presets
      : presets.where((p) => p.instrument == _filter).toList();

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _select(TuningPreset preset) async {
    HapticFeedback.selectionClick();
    await controller.setActivePreset(preset);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _openEditor({TuningPreset? existing, TuningPreset? base}) async {
    await Navigator.of(context).push(
      SharedAxisVerticalPageRoute(
        builder: (_) => PresetEditorScreen(
          controller: controller,
          existing: existing,
          base: base,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(TuningPreset preset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceBright,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(context.l10n.deleteDialogTitle),
        content: Text(
          context.l10n.deleteDialogBody(preset.displayName(context.l10n)),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteCustomPreset(preset.id);
    }
  }

  /// Anima a entrada do item [index] com atraso progressivo (stagger).
  Widget _staggered(int index, Widget child) {
    final start = (0.06 * index).clamp(0.0, 0.6);
    final animation = CurvedAnimation(
      parent: _entrance,
      curve: Interval(
        start,
        (start + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final custom = _applyFilter(controller.customPresets);
        final builtIns = _applyFilter(controller.builtInPresets);
        var itemIndex = 0;
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openEditor(),
            backgroundColor: AppColors.mint,
            foregroundColor: const Color(0xFF04291C),
            icon: const Icon(Icons.add_rounded),
            label: Text(
              context.l10n.newPreset,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          body: BackdropGroup(
            child: CustomScrollView(
              slivers: [
                SliverAppBar.large(
                  title: Text(context.l10n.presetsTitle),
                  backgroundColor: AppColors.background,
                ),
                SliverToBoxAdapter(
                  child: _staggered(
                    itemIndex++,
                    _InstrumentFilterBar(
                      selected: _filter,
                      onChanged: (value) {
                        HapticFeedback.selectionClick();
                        setState(() => _filter = value);
                      },
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: _staggered(
                      itemIndex++,
                      _SectionHeader(context.l10n.sectionMyPresets),
                    ),
                  ),
                ),
                if (custom.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: _staggered(
                        itemIndex++,
                        _EmptyCustomCard(filtered: _filter != null),
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.builder(
                    itemCount: custom.length,
                    itemBuilder: (context, i) => _staggered(
                      itemIndex + i,
                      _PresetTile(
                        preset: custom[i],
                        isActive: controller.activePreset.id == custom[i].id,
                        onTap: () => _select(custom[i]),
                        menu: [
                          _MenuAction(
                            context.l10n.menuEdit,
                            Icons.edit_rounded,
                            () => _openEditor(existing: custom[i]),
                          ),
                          _MenuAction(
                            context.l10n.menuDuplicate,
                            Icons.copy_rounded,
                            () => _openEditor(base: custom[i]),
                          ),
                          _MenuAction(
                            context.l10n.menuDelete,
                            Icons.delete_rounded,
                            () => _confirmDelete(custom[i]),
                            destructive: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: _staggered(
                      itemIndex + custom.length,
                      _SectionHeader(context.l10n.sectionBuiltIn),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                  sliver: SliverList.builder(
                    itemCount: builtIns.length,
                    itemBuilder: (context, i) {
                      final preset = builtIns[i];
                      return _staggered(
                        itemIndex + custom.length + 1 + i,
                        _PresetTile(
                          preset: preset,
                          isActive: controller.activePreset.id == preset.id,
                          onTap: () => _select(preset),
                          menu: [
                            _MenuAction(
                              context.l10n.menuDuplicateEdit,
                              Icons.copy_rounded,
                              () => _openEditor(base: preset),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _InstrumentFilterBar extends StatelessWidget {
  const _InstrumentFilterBar({required this.selected, required this.onChanged});

  final Instrument? selected;
  final ValueChanged<Instrument?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (final entry in <(Instrument?, String)>[
            (null, context.l10n.filterAll),
            for (final instrument in Instrument.values)
              (instrument, instrument.label(context.l10n)),
          ])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(entry.$2),
                selected: selected == entry.$1,
                showCheckmark: false,
                selectedColor: AppColors.mint.withValues(alpha: 0.18),
                backgroundColor: AppColors.surfaceBright,
                side: BorderSide(
                  color: selected == entry.$1
                      ? AppColors.mint
                      : AppColors.outline,
                ),
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected == entry.$1
                      ? AppColors.mint
                      : AppColors.textSecondary,
                ),
                onSelected: (_) => onChanged(entry.$1),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyCustomCard extends StatelessWidget {
  const _EmptyCustomCard({required this.filtered});

  /// Verdadeiro quando a lista está vazia por causa do filtro ativo.
  final bool filtered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.violet),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              filtered
                  ? context.l10n.emptyCustomFiltered
                  : context.l10n.emptyCustom,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.45,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuAction {
  const _MenuAction(
    this.label,
    this.icon,
    this.onSelected, {
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onSelected;
  final bool destructive;
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.preset,
    required this.isActive,
    required this.onTap,
    required this.menu,
  });

  final TuningPreset preset;
  final bool isActive;
  final VoidCallback onTap;
  final List<_MenuAction> menu;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: AppColors.mint.withValues(alpha: 0.18),
              blurRadius: 24,
              spreadRadius: -6,
            ),
        ],
      ),
      child: LiquidGlass(
        radius: 22,
        blur: 20,
        rim: 10,
        tint: isActive ? AppColors.mint : null,
        tintOpacity: 0.14,
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        child: Row(
          children: [
            Hero(
              tag: 'preset-avatar-${preset.id}',
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isActive
                          ? [AppColors.mint, const Color(0xFF19B380)]
                          : [AppColors.surfaceBright, const Color(0xFF1D2A3D)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${preset.notes.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: isActive
                            ? const Color(0xFF04291C)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.displayName(context.l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${preset.instrument.label(context.l10n)} · '
                    '${preset.notes.join(' ')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedScale(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              scale: isActive ? 1.0 : 0.0,
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.mint,
                size: 22,
              ),
            ),
            PopupMenuButton<int>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textSecondary,
              ),
              color: AppColors.surfaceBright,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              itemBuilder: (context) => [
                for (var i = 0; i < menu.length; i++)
                  PopupMenuItem(
                    value: i,
                    child: Row(
                      children: [
                        Icon(
                          menu[i].icon,
                          size: 19,
                          color: menu[i].destructive
                              ? AppColors.coral
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          menu[i].label,
                          style: TextStyle(
                            color: menu[i].destructive
                                ? AppColors.coral
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              onSelected: (index) => menu[index].onSelected(),
            ),
          ],
        ),
      ),
    );
  }
}
