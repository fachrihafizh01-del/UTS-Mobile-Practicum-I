import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tapak/data/exercise_repository.dart';
import 'package:tapak/models/exercise.dart';
import 'package:tapak/pages/home_page.dart';
import 'package:tapak/utils/app_theme.dart';

/// Repository palsu agar test tidak bergantung pada aset JSON.
class _FakeRepository implements ExerciseRepository {
  _FakeRepository(this.items);

  final List<Exercise> items;

  @override
  Future<List<Exercise>> fetchExercises({String? kategori}) async {
    if (kategori == null) return items;
    return items.where((item) => item.kategori == kategori).toList();
  }

  @override
  Future<Exercise?> fetchExerciseById(String id) async {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}

Exercise _exercise({
  required String id,
  required String nama,
  required String kategori,
  bool populer = false,
}) {
  return Exercise(
    id: id,
    nama: nama,
    kategori: kategori,
    deskripsi: 'Deskripsi $nama.',
    gambar: '',
    durasiDetik: 60,
    repetisi: '2 set x 8',
    tingkat: 'Ringan',
    posisi: 'Duduk',
    target: const <String>['Leher'],
    tujuan: 'Tujuan $nama.',
    langkah: const <String>['Langkah 1'],
    kesalahanUmum: const <String>['Kesalahan 1'],
    manfaat: const <String>['Manfaat 1'],
    populer: populer,
  );
}

void main() {
  setUpAll(() {
    // Jangan unduh font saat test berjalan.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Beranda menampilkan seluruh bagian utama', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532); // 390 x 844 @3x
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final repository = _FakeRepository(<Exercise>[
      _exercise(
        id: 'ex-001',
        nama: 'Putar Leher',
        kategori: 'leher-bahu',
        populer: true,
      ),
      _exercise(id: 'ex-004', nama: 'Peregangan Dada', kategori: 'punggung'),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: HomePage(repository: repository),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Selamat ${_greeting()},'), findsOneWidget);
    expect(find.text('AREA TUBUH'), findsOneWidget);

    // Scroll untuk menjangkau bagian "Populer" & "Terbaru" (lazy building).
    final scrollable = find.byType(Scrollable).first;
    await tester.dragUntilVisible(
      find.text('POPULER'),
      scrollable,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    expect(find.text('POPULER'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('TERBARU'),
      scrollable,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    expect(find.text('TERBARU'), findsOneWidget);

    expect(find.text('Leher & Bahu'), findsWidgets);
  });

  testWidgets('Pencarian menyaring daftar gerakan', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final repository = _FakeRepository(<Exercise>[
      _exercise(id: 'ex-001', nama: 'Putar Leher', kategori: 'leher-bahu'),
      _exercise(id: 'ex-004', nama: 'Peregangan Dada', kategori: 'punggung'),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: HomePage(repository: repository),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'dada');
    await tester.pumpAndSettle();

    expect(find.text('HASIL PENCARIAN'), findsOneWidget);
    expect(find.text('Peregangan Dada'), findsOneWidget);
    expect(find.text('Putar Leher'), findsNothing);
  });
}

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 11) return 'pagi';
  if (hour < 15) return 'siang';
  if (hour < 19) return 'sore';
  return 'malam';
}
