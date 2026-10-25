import 'package:flutter/material.dart';

import '../data/exercise_repository.dart';
import '../data/repository_provider.dart';
import '../models/exercise.dart';
import '../utils/app_categories.dart';
import '../utils/app_theme.dart';
import 'detail_page.dart';
import 'list_page.dart';

/// Halaman Beranda Tapak.
///
/// Susunan: sapaan → pencarian → kartu sesi hari ini → kategori →
/// "Populer" (horizontal) → "Terbaru" (vertikal).
/// Semua data berasal dari [ExerciseRepository] (JSON lokal atau API).
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.repository,
    this.onCategoryTap,
    this.onExerciseTap,
  });

  /// Opsional: memudahkan unit test / injeksi repository lain.
  final ExerciseRepository? repository;

  /// Callback navigasi. Bila null, halaman menampilkan pesan sementara
  /// (navigasi ke halaman daftar & detail ditambahkan pada tahap berikutnya).
  final ValueChanged<String>? onCategoryTap;
  final ValueChanged<Exercise>? onExerciseTap;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List<String> _hari = <String>[
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _bulan = <String>[
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  late final ExerciseRepository _repository;
  late Future<List<Exercise>> _future;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? RepositoryProvider.exerciseRepository;
    _future = _repository.fetchExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Dipakai oleh RefreshIndicator: muat ulang data dari sumbernya.
  Future<void> _refresh() async {
    final future = _repository.fetchExercises();
    setState(() => _future = future);
    await future;
  }

  /// Pencarian sederhana di sisi klien (nama, deskripsi, kategori, target).
  List<Exercise> _filter(List<Exercise> source) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return source;

    return source.where((exercise) {
      final haystack = <String>[
        exercise.nama,
        exercise.deskripsi,
        AppCategories.labelOf(exercise.kategori),
        ...exercise.target,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList(growable: false);
  }

  // --- Navigasi -----------------------------------------------------------
  // TODO(navigasi): ganti isi method ini dengan Navigator.push ke
  // CategoryPage / DetailPage setelah kedua halaman tersebut dibuat.

  void _openCategory(String kategoriId) {
    if (widget.onCategoryTap != null) {
      widget.onCategoryTap!(kategoriId);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ListPage(kategoriId: kategoriId),
      ),
    );
  }

  void _openExercise(Exercise exercise) {
    if (widget.onExerciseTap != null) {
      widget.onExerciseTap!(exercise);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailPage(exercise: exercise),
      ),
    );
  }

  // Menampilkan placeholder bila callback tidak disediakan (opsional).

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

            final all = snapshot.data ?? const <Exercise>[];

            // LayoutBuilder: lebar konten & jumlah kolom mengikuti layar.
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isTablet = width >= 600;
                final horizontalPadding =
                    width >= 900 ? 32.0 : (isTablet ? 24.0 : 16.0);
                final categoryColumns = width >= 1200 ? 4 : (isTablet ? 3 : 2);
                final popularCardWidth = isTablet ? 232.0 : 208.0;

                // Preferensi ukuran teks sistem memengaruhi tinggi kartu
                // horizontal agar judul tidak terpotong.
                final textFactor = MediaQuery.textScalerOf(context)
                    .scale(1.0)
                    .clamp(1.0, 1.3)
                    .toDouble();
                final popularHeight = 196 * textFactor;

                final isSearching = _query.trim().isNotEmpty;
                final results = _filter(all);

                return Center(
                  // Di tablet/desktop konten tidak melebar berlebihan.
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      color: AppColors.primary,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          AppSpacing.md,
                          horizontalPadding,
                          AppSpacing.xxl,
                        ),
                        children: <Widget>[
                          _buildHeader(context),
                          const SizedBox(height: AppSpacing.xl),
                          _buildSearchField(context),
                          const SizedBox(height: AppSpacing.xl),

                          if (!isSearching) ...<Widget>[
                            _buildTodayCard(context, all),
                            const SizedBox(height: AppSpacing.xxl),
                            _SectionHeader(
                              title: 'Area tubuh',
                              trailing: '${AppCategories.all.length} kategori',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _buildCategoryGrid(
                              all,
                              columns: categoryColumns,
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            _SectionHeader(
                              title: 'Populer',
                              trailing: 'Paling sering dibuka',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _buildPopularList(
                              all,
                              height: popularHeight,
                              cardWidth: popularCardWidth,
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            const _SectionHeader(title: 'Terbaru'),
                            const SizedBox(height: AppSpacing.md),
                            _buildRecentList(all),
                          ] else ...<Widget>[
                            _SectionHeader(
                              title: 'Hasil pencarian',
                              trailing: '${results.length} gerakan',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            if (results.isEmpty)
                              _EmptySearchView(
                                query: _query,
                                onReset: _clearSearch,
                              )
                            else
                              _buildRecentList(results),
                          ],
                        ],
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

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  // --- Header & pencarian -------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_formatDate(DateTime.now()), style: text.labelSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Selamat ${_greeting()},',
                style: text.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Beri jeda 5 menit untuk tubuhmu.',
                style: text.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_rounded, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A1E2A28),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        textInputAction: TextInputAction.search,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Cari gerakan, mis. "leher"',
          hintStyle: Theme.of(context).textTheme.bodyMedium,
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slate),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close_rounded),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
          ),
        ),
      ),
    );
  }

  // --- Kartu sesi hari ini ------------------------------------------------

  Widget _buildTodayCard(BuildContext context, List<Exercise> all) {
    final text = Theme.of(context).textTheme;
    final neck = all
        .where((exercise) => exercise.kategori == 'leher-bahu')
        .toList(growable: false);
    final totalMenit = neck.isEmpty
        ? 4
        : (neck.fold<int>(0, (sum, item) => sum + item.durasiDetik) / 60).ceil();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: AppRadius.heroRadius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.primary, Color(0xFF24594C)],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1F2F6F5E),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.bolt_rounded,
                size: 18,
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'SESI HARI INI',
                style: text.labelSmall?.copyWith(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Leher & Bahu',
            style: text.displaySmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${neck.isEmpty ? 3 : neck.length} gerakan · ± $totalMenit menit',
            style: text.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: () => _openCategory('leher-bahu'),
            icon: const Icon(Icons.play_arrow_rounded, size: 20),
            label: const Text('Mulai sekarang'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            ),
          ),
        ],
      ),
    );
  }

  // --- Kategori -----------------------------------------------------------

  Widget _buildCategoryGrid(List<Exercise> all, {required int columns}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: AppCategories.all.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        mainAxisExtent: 128,
      ),
      itemBuilder: (context, index) {
        final category = AppCategories.all[index];
        final count = all
            .where((exercise) => exercise.kategori == category.id)
            .length;

        return _CategoryCard(
          nama: category.nama,
          ikon: category.ikon,
          warna: category.warna,
          jumlah: count,
          onTap: () => _openCategory(category.id),
        );
      },
    );
  }

  // --- Populer (ListView horizontal) --------------------------------------

  Widget _buildPopularList(
    List<Exercise> all, {
    required double height,
    required double cardWidth,
  }) {
    // Ambil yang ditandai populer; bila kosong pakai data teratas sebagai
    // fallback agar bagian ini tidak pernah tampil kosong.
    final popular = all.where((exercise) => exercise.populer).toList();
    final items = popular.isEmpty ? all.take(5).toList() : popular;

    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final exercise = items[index];
          return SizedBox(
            width: cardWidth,
            child: _PopularCard(
              exercise: exercise,
              onTap: () => _openExercise(exercise),
            ),
          );
        },
      ),
    );
  }

  // --- Terbaru (list vertikal) --------------------------------------------

  Widget _buildRecentList(List<Exercise> items) {
    // "Terbaru" = data paling akhir ditambahkan (urutan id menurun).
    final recent = items.reversed.take(5).toList(growable: false);

    return Column(
      children: <Widget>[
        for (var index = 0; index < recent.length; index++) ...<Widget>[
          if (index > 0) const SizedBox(height: AppSpacing.md),
          _RecentCard(
            exercise: recent[index],
            onTap: () => _openExercise(recent[index]),
          ),
        ],
      ],
    );
  }

  // --- Util tanggal -------------------------------------------------------

  String _formatDate(DateTime date) {
    final namaHari = _hari[date.weekday - 1];
    final namaBulan = _bulan[date.month - 1];
    return '$namaHari, ${date.day} $namaBulan ${date.year}'.toUpperCase();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'pagi';
    if (hour < 15) return 'siang';
    if (hour < 19) return 'sore';
    return 'malam';
  }
}

// ---------------------------------------------------------------------------
// Widget pendukung (dipisah agar build method beranda tetap ringkas).
// ---------------------------------------------------------------------------

/// Judul bagian dengan teks pendukung di kanan.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: text.labelSmall,
          ),
        ),
        if (trailing != null)
          Flexible(
            child: Text(
              trailing!,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall,
            ),
          ),
      ],
    );
  }
}

/// Kartu kategori pada grid beranda.
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.nama,
    required this.ikon,
    required this.warna,
    required this.jumlah,
    required this.onTap,
  });

  final String nama;
  final IconData ikon;
  final Color warna;
  final int jumlah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.cardRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardRadius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppRadius.cardRadius,
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: warna.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(ikon, color: warna, size: 20),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.mist,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleMedium,
                ),
                const SizedBox(height: 2),
                Text('$jumlah gerakan', style: text.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu pada daftar horizontal "Populer".
class _PopularCard extends StatelessWidget {
  const _PopularCard({required this.exercise, required this.onTap});

  final Exercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final category = AppCategories.byId(exercise.kategori);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
        side: const BorderSide(color: AppColors.surfaceVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 92,
              width: double.infinity,
              child: _ExerciseThumb(exercise: exercise),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    exercise.nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${category.nama} · ${exercise.durasiLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: category.warna,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      // Expanded: teks repetisi mengikuti sisa lebar kartu.
                      Expanded(
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
      ),
    );
  }
}

/// Kartu pada daftar vertikal "Terbaru" / hasil pencarian.
class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.exercise, required this.onTap});

  final Exercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final category = AppCategories.byId(exercise.kategori);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
        side: const BorderSide(color: AppColors.surfaceVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category.warna.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Icon(category.ikon, color: category.warna, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      exercise.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${category.nama} · ${exercise.durasiLabel} · ${exercise.tingkat}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.mist,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gambar gerakan dengan fallback ikon bila aset belum tersedia.
/// Mendukung path lokal (JSON) maupun URL (API).
class _ExerciseThumb extends StatelessWidget {
  const _ExerciseThumb({required this.exercise});

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
            category.warna.withValues(alpha: 0.20),
            category.warna.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Icon(category.ikon, size: 34, color: category.warna),
      ),
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

/// Tampilan saat pencarian tidak menemukan hasil.
class _EmptySearchView extends StatelessWidget {
  const _EmptySearchView({required this.query, required this.onReset});

  final String query;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 32,
              color: AppColors.slate,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Tidak ada hasil untuk "$query"', style: text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Coba kata kunci lain seperti "punggung" atau "pergelangan".',
            textAlign: TextAlign.center,
            style: text.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextButton(onPressed: onReset, child: const Text('Hapus pencarian')),
        ],
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
