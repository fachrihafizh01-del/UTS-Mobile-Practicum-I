import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/list_page.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TapakApp());
}

class TapakApp extends StatelessWidget {
  const TapakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tapak',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Beranda jadi halaman awal
      home: const MainShell(),
    );
  }
}

/// Shell utama dengan BottomNavigationBar.
/// Menu: Beranda, Latihan (daftar cepat per kategori), Tentang.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    _CategoryOverviewPage(),
    _AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Latihan',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline_rounded),
            selectedIcon: Icon(Icons.info_rounded),
            label: 'Tentang',
          ),
        ],
      ),
    );
  }
}

/// Halaman ringkas untuk mengakses daftar per kategori langsung dari menu bawah.
class _CategoryOverviewPage extends StatelessWidget {
  const _CategoryOverviewPage();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final items = <_CatItem>[
      const _CatItem(id: 'leher-bahu', title: 'Leher & Bahu', subtitle: 'Redakan kaku setelah menunduk', icon: Icons.accessibility_new_rounded, color: Color(0xFFD97757)),
      const _CatItem(id: 'punggung', title: 'Punggung', subtitle: 'Postur & kelenturan tulang belakang', icon: Icons.airline_seat_recline_normal_rounded, color: Color(0xFF3E7C8C)),
      const _CatItem(id: 'pergelangan-tangan', title: 'Pergelangan Tangan', subtitle: 'Kurangi tegang akibat mengetik', icon: Icons.back_hand_rounded, color: Color(0xFFC89B3C)),
      const _CatItem(id: 'kaki', title: 'Kaki', subtitle: 'Aktifkan kaki yang jarang bergerak', icon: Icons.directions_walk_rounded, color: Color(0xFF7A6A9B)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Kategori'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final padding = width >= 900 ? 32.0 : (width >= 600 ? 24.0 : 16.0);
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(padding, AppSpacing.md, padding, AppSpacing.xxl),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.cardRadius,
                        side: const BorderSide(color: AppColors.surfaceVariant),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(AppSpacing.lg),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.icon, color: item.color),
                        ),
                        title: Text(item.title, style: text.titleMedium),
                        subtitle: Text(item.subtitle, style: text.bodySmall),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.mist),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ListPage(kategoriId: item.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CatItem {
  const _CatItem({required this.id, required this.title, required this.subtitle, required this.icon, required this.color});
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _AboutPage extends StatelessWidget {
  const _AboutPage();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Tapak')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppRadius.cardRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Tapak', style: text.headlineMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Panduan peregangan & ergonomi untuk pekerja layar. Dibuat untuk tugas UTS Mobile Programming dengan fokus pada UI/UX, navigasi, widget & layout, dan data dummy.',
                    style: text.bodyMedium?.copyWith(color: AppColors.ink),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Fitur', style: text.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            const _AboutTile(icon: Icons.home_rounded, title: 'Beranda', subtitle: 'Sambutan, kategori, populer & terbaru'),
            const _AboutTile(icon: Icons.grid_view_rounded, title: 'Latihan per kategori', subtitle: 'ListView dengan Card & tombol Lihat Detail'),
            const _AboutTile(icon: Icons.article_outlined, title: 'Detail gerakan', subtitle: 'Langkah, peringatan, kesalahan umum & manfaat'),
            const _AboutTile(icon: Icons.storage_rounded, title: 'Data dummy siap API', subtitle: 'Model, repository, rootBundle/http'),
            const SizedBox(height: AppSpacing.xl),
            Text('Alur Navigasi', style: text.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Beranda (BottomNav) → tekan kategori / "Populer"/"Terbaru" → Daftar (ListPage) → "Lihat Detail" → Detail (DetailPage) → tombol kembali (Navigator.pop)',
              style: text.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: text.titleMedium),
      subtitle: Text(subtitle, style: text.bodySmall),
    );
  }
}
