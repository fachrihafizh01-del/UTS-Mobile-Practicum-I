import 'package:flutter/material.dart';

import '../data/exercise_repository.dart';
import '../data/repository_provider.dart';
import '../models/exercise.dart';
import '../utils/app_categories.dart';
import '../utils/app_theme.dart';

/// Halaman Detail Gerakan.
///
/// Menampilkan tujuan, cara melakukan (langkah), peringatan,
/// kesalahan umum, manfaat, target, serta tombol "Tandai sudah dilakukan".
/// Dapat menerima [Exercise] langsung atau [exerciseId] untuk dimuat via repository.
class DetailPage extends StatefulWidget {
  DetailPage({
    super.key,
    this.exercise,
    this.exerciseId,
    this.repository,
  }) : assert(
          exercise != null || (exerciseId != null && exerciseId.isNotEmpty),
          'DetailPage membutuhkan exercise atau exerciseId.',
        );

  /// Data gerakan (bisa dikirim langsung dari halaman sebelumnya).
  final Exercise? exercise;

  /// ID gerakan (untuk dimuat via repository bila data tidak dikirim).
  final String? exerciseId;

  /// Opsional: injeksi repository.
  final ExerciseRepository? repository;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late final ExerciseRepository _repository;
  Exercise? _exercise;
  bool _loading = false;
  Object? _error;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? RepositoryProvider.exerciseRepository;
    _exercise = widget.exercise;

    if (_exercise == null && widget.exerciseId != null) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final id = widget.exerciseId;
      if (id == null || id.isEmpty) {
        setState(() {
          _error = StateError('exerciseId tidak valid.');
          _loading = false;
        });
        return;
      }
      final result = await _repository.fetchExerciseById(id);
      setState(() {
        _exercise = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _toggleDone() {
    setState(() => _done = !_done);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _done
                ? 'Tercatat: "${_exercise?.nama}" sudah dilakukan.'
                : 'Ditandai belum dilakukan.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _done ? AppColors.success : AppColors.ink,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _exercise;

    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null || exercise == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Kembali',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: _ErrorView(
          message: _error?.toString() ??
              'Data gerakan tidak ditemukan. Kembali dan coba lagi.',
          onRetry: _exercise == null && widget.exerciseId != null ? _load : null,
        ),
      );
    }

    final category = AppCategories.byId(exercise.kategori);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            backgroundColor: category.warna,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              tooltip: 'Kembali',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            actions: <Widget>[
              IconButton(
                tooltip: 'Bagikan',
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Fitur bagikan akan segera hadir.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                },
                icon: const Icon(Icons.ios_share_rounded, color: Colors.white),
              ),
              IconButton(
                tooltip: 'Simpan',
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Disimpan ke koleksi (lokal).'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                },
                icon: const Icon(Icons.bookmark_border_rounded, color: Colors.white),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const <StretchMode>[
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              title: Text(
                exercise.nama,
                style: text.titleLarge?.copyWith(color: Colors.white),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          category.warna,
                          Color.lerp(category.warna, Colors.black, 0.25)!,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -24,
                    bottom: -36,
                    child: Icon(
                      category.ikon,
                      size: 160,
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      kToolbarHeight + AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          category.nama.toUpperCase(),
                          style: text.labelSmall?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          exercise.nama,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.displaySmall?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: <Widget>[
                            _InfoChip(
                              icon: Icons.timer_outlined,
                              label: exercise.durasiLabel,
                            ),
                            _InfoChip(
                              icon: Icons.repeat_rounded,
                              label: exercise.repetisi,
                            ),
                            _InfoChip(
                              icon: Icons.signal_cellular_alt_rounded,
                              label: exercise.tingkat,
                            ),
                            _InfoChip(
                              icon: Icons.chair_outlined,
                              label: exercise.posisi,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xxxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _SectionTitle(title: 'Tujuan'),
                      const SizedBox(height: AppSpacing.sm),
                      Text(exercise.tujuan, style: text.bodyLarge),
                      const SizedBox(height: AppSpacing.xl),
                      _SectionTitle(title: 'Target Otot / Area'),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: exercise.target
                            .map(
                              (t) => Chip(
                                label: Text(t),
                                backgroundColor: AppColors.primaryContainer,
                                side: BorderSide.none,
                                labelStyle: text.labelMedium?.copyWith(
                                  color: AppColors.ink,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _SectionTitle(title: 'Cara Melakukan'),
                      const SizedBox(height: AppSpacing.sm),
                      ..._buildSteps(context, exercise.langkah),
                      if (exercise.memilikiPeringatan) ...<Widget>[
                        const SizedBox(height: AppSpacing.xl),
                        _WarningCard(text: exercise.peringatan!),
                      ],
                      if (exercise.kesalahanUmum.isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppSpacing.xl),
                        _SectionTitle(title: 'Kesalahan Umum'),
                        const SizedBox(height: AppSpacing.sm),
                        ...exercise.kesalahanUmum.map(
                          (k) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Icon(
                                    Icons.cancel_outlined,
                                    size: 16,
                                    color: AppColors.warning,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(k, style: text.bodyMedium?.copyWith(color: AppColors.ink)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (exercise.manfaat.isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppSpacing.xl),
                        _SectionTitle(title: 'Manfaat'),
                        const SizedBox(height: AppSpacing.sm),
                        ...exercise.manfaat.map(
                          (m) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 18,
                                    color: AppColors.success,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(m, style: text.bodyMedium?.copyWith(color: AppColors.ink)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: FilledButton.icon(
            onPressed: _toggleDone,
            icon: Icon(_done ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded),
            label: Text(_done ? 'Sudah dilakukan' : 'Tandai sudah dilakukan'),
            style: FilledButton.styleFrom(
              backgroundColor: _done ? AppColors.success : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSteps(BuildContext context, List<String> langkah) {
    final text = Theme.of(context).textTheme;
    final widgets = <Widget>[];
    for (var i = 0; i < langkah.length; i++) {
      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: i == langkah.length - 1 ? 0 : AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: text.labelLarge?.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(langkah[i], style: text.bodyLarge),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Text(title, style: text.titleLarge);
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.chip)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: text.labelMedium?.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Perhatian',
                  style: textStyle.titleMedium?.copyWith(color: AppColors.ink),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(text, style: textStyle.bodyMedium?.copyWith(color: AppColors.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.slate),
            const SizedBox(height: AppSpacing.lg),
            Text('Tidak dapat menampilkan detail', style: text.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(message, textAlign: TextAlign.center, style: text.bodyMedium),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xl),
              FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
            ],
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
