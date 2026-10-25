import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tapak/models/exercise.dart';

void main() {
  group('Exercise.fromJson', () {
    test('membaca field lengkap dengan benar', () {
      final json = jsonDecode('''
        {
          "id": "ex-001",
          "nama": "Putar Leher",
          "kategori": "leher-bahu",
          "deskripsi": "Pemanasan leher.",
          "gambar": "assets/images/gerakan/putar-leher.webp",
          "durasiDetik": 90,
          "repetisi": "2 set x 8",
          "tingkat": "Ringan",
          "posisi": "Duduk",
          "target": ["Leher"],
          "tujuan": "Mengurangi kaku.",
          "langkah": ["Langkah 1", "Langkah 2"],
          "kesalahanUmum": ["Terlalu cepat"],
          "peringatan": null,
          "manfaat": ["Rileks"]
        }
      ''') as Map<String, dynamic>;

      final exercise = Exercise.fromJson(json);

      expect(exercise.id, 'ex-001');
      expect(exercise.nama, 'Putar Leher');
      expect(exercise.kategori, 'leher-bahu');
      expect(exercise.durasiDetik, 90);
      expect(exercise.durasiLabel, '1 mnt 30 dtk');
      expect(exercise.langkah, hasLength(2));
      expect(exercise.memilikiPeringatan, isFalse);
    });

    test('memberi nilai default saat field hilang', () {
      final exercise = Exercise.fromJson(<String, dynamic>{
        'id': 'ex-x',
        'nama': 'Tanpa Data',
      });

      expect(exercise.tingkat, 'Ringan');
      expect(exercise.posisi, 'Duduk');
      expect(exercise.durasiDetik, 0);
      expect(exercise.target, isEmpty);
      expect(exercise.peringatan, isNull);
    });

    test('toJson menghasilkan struktur yang sama', () {
      final exercise = Exercise.fromJson(<String, dynamic>{
        'id': 'ex-002',
        'nama': 'Angkat Bahu',
        'kategori': 'leher-bahu',
        'durasiDetik': 60,
      });

      final json = exercise.toJson();

      expect(json['id'], 'ex-002');
      expect(json['durasiDetik'], 60);
      expect(Exercise.fromJson(json).nama, 'Angkat Bahu');
    });
  });
}
