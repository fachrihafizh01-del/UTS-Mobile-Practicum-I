import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tapak/data/exercise_repository.dart';
import 'package:tapak/models/exercise.dart';
import 'package:tapak/pages/list_page.dart';
import 'package:tapak/utils/app_theme.dart';

class _FakeRepository implements ExerciseRepository {
  _FakeRepository(this.items);

  final List<Exercise> items;

  @override
  Future<List<Exercise>> fetchExercises({String? kategori}) async {
    if (kategori == null || kategori.isEmpty) return items;
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
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('ListPage menampilkan daftar berdasarkan kategori', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final repository = _FakeRepository(<Exercise>[
      _exercise(id: 'ex-001', nama: 'Putar Leher', kategori: 'leher-bahu'),
      _exercise(id: 'ex-002', nama: 'Peregangan Samping', kategori: 'leher-bahu'),
      _exercise(id: 'ex-004', nama: 'Peregangan Dada', kategori: 'punggung'),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: ListPage(kategoriId: 'leher-bahu', repository: repository),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Leher & Bahu'), findsWidgets);
    expect(find.text('Putar Leher'), findsOneWidget);
    expect(find.text('Peregangan Samping'), findsOneWidget);
    expect(find.text('Peregangan Dada'), findsNothing);
    expect(find.text('Lihat Detail'), findsNWidgets(2));
  });

  testWidgets('ListPage menampilkan state kosong bila data tidak ada', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final repository = _FakeRepository(<Exercise>[
      _exercise(id: 'ex-004', nama: 'Peregangan Dada', kategori: 'punggung'),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: ListPage(kategoriId: 'kaki', repository: repository),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada gerakan'), findsOneWidget);
    expect(find.text('Kembali ke Beranda'), findsOneWidget);
    expect(find.text('Lihat Detail'), findsNothing);
  });
}
