import 'package:flutter/material.dart';

import '../data/exercise_repository.dart';
import '../data/repository_provider.dart';
import '../models/exercise.dart';
import '../utils/app_categories.dart';
import '../utils/app_theme.dart';
import 'detail_page.dart';

/// Halaman Daftar per Kategori.
///
/// Menerima [kategoriId] yang dikirim dari [HomePage] lewat constructor.
/// Menampilkan daftar gerakan berdasarkan kategori, dilengkapi thumbnail,
/// judul, subjudul, tombol "Lihat Detail", serta state kosong bila data tidak ada.
class ListPage extends StatefulWidget {
  const ListPage({
    super.key,
    required this.kategoriId,
    this.repository,
    this.onDetailTap,
  });

  /// Slug kategori: leher-bahu | punggung | pergelangan-tangan | kaki.
  final String kategoriId;

  /// Opsional: injeksi repository (berguna untuk unit test).
  final ExerciseRepository? repository;

  /// Callback saat tombol "Lihat Detail" ditekan.
  /// Jika null, tampilkan SnackBar placeholder hingga DetailPage dibuat.
  final ValueChanged<Exercise>? onDetailTap;

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late final ExerciseRepository _repository;
  late Future<List<Exercise>> _future;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? RepositoryProvider.exerciseRepository;
    _future = _repository.fetchExercises(kategori: widget.kategoriId);
  }

  Future<void> _refresh() async {
    final future = _repository.fetchExercises(kategori: widget.kategoriId);
    setState(() => _future = future);
    await future;
  }

  void _openDetail(Exercise exercise) {
    if (widget.onDetailTap != null) {
      widget.onDetailTap!(exercise);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailPage(exercise: exercise),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = AppCategories.byId(widget.kategoriId);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(category.nama),
        actions: <Widget>[
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<Exercise>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
              return _ErrorView(
                message: snapshot.error.toString(),
                onRetry: _refresh,
              );
            }

            final items = snapshot.data ?? const <Exercise>[];

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isTablet = width >= 600;
                final horizontalPadding =
                    width >= 900 ? 32.0 : (isTablet ? 24.0 : 16.0);

                if (items.isEmpty) {
                  return _EmptyState(
                    category: category,
                    horizontalPadding: horizontalPadding,
                  );
                }

                // ListView.builder dengan Card.
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      color: AppColors.primary,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          AppSpacing.md,
                          horizontalPadding,
                          AppSpacing.xxl,
                        ),
                        itemCount: items.length + 1,
                        itemBuilder: (context, index) {
                          // Header ringkas: jumlah gerakan per kategori.
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                              child: _CategoryHeader(
                                category: category,
                                count: items.length,
                              ),
                            );
                          }

                          final exercise = items[index - 1];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _ExerciseListCard(
                              exercise: exercise,
                              onDetailTap: () => _openDetail(exercise),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Header kategori di atas daftar.
class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category, required this.count});

  final CategoryInfo category;
  final int count;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: category.warna.withValues(alpha: 0.12),
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: category.warna.withValues(alpha: 0.40)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(category.ikon, color: category.warna, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  category.nama,
                  style: text.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  '$count gerakan · ${category.deskripsi}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card daftar: thumbnail, judul, subjudul, tombol "Lihat Detail".
class _ExerciseListCard extends StatelessWidget {
  const _ExerciseListCard({
    required this.exercise,
    required this.onDetailTap,
  });

  final Exercise exercise;
  final VoidCallback onDetailTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final category = AppCategories.byId(exercise.kategori);

    // Subjudul: Area + durasi + tingkat posisi.
    final subjudul =
        '${category.nama} · ${exercise.durasiLabel} · ${exercise.tingkat} · ${exercise.posisi}';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
        side: const BorderSide(color: AppColors.surfaceVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: _ListThumb(exercise: exercise),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Judul + subjudul
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        exercise.nama,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subjudul,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.repeat_rounded,
                            size: 14,
                            color: category.warna,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              exercise.repetisi,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.labelMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Tombol "Lihat Detail" (sejajar penuh agar mudah disentuh).
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onDetailTap,
                icon: const Icon(Icons.article_outlined, size: 18),
                label: const Text('Lihat Detail'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  minimumSize: const Size.fromHeight(44),
                  shape: const StadiumBorder(),
                  textStyle: text.labelLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thumbnail untuk list: aset lokal / URL / fallback ikon kategori.
class _ListThumb extends StatelessWidget {
  const _ListThumb({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final category = AppCategories.byId(exercise.kategori);

    final fallback = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            category.warna.withValues(alpha: 0.25),
            category.warna.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Icon(category.ikon, color: category.warna, size: 26),
    );

    if (exercise.gambar.isEmpty) return fallback;

    if (exercise.gambar.startsWith('http')) {
      return Image.network(
        exercise.gambar,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    return Image.asset(
      exercise.gambar,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

/// State kosong ketika tidak ada data untuk kategori ini.
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.category,
    required this.horizontalPadding,
  });

  final CategoryInfo category;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: category.warna.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.ikon,
                size: 38,
                color: category.warna,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Belum ada gerakan',
              textAlign: TextAlign.center,
              style: text.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Belum ada data gerakan untuk kategori "${category.nama}".\n'
              'Tambahkan item di assets/data/exercises.json atau ganti ke API.',
              textAlign: TextAlign.center,
              style: text.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Kembali ke Beranda'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tampilan error dengan tombol coba lagi.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.slate,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Data gagal dimuat', style: text.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
