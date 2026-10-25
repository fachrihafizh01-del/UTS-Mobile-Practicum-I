import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../models/exercise.dart';
import 'exercise_repository.dart';

/// Implementasi repository yang membaca JSON dari bundle aplikasi.
///
/// Hasil parsing di-cache di memori supaya berpindah halaman tidak
/// membaca ulang aset. Dukungan dua bentuk JSON:
///   1. Array langsung: `[ {...}, {...} ]`
///   2. Objek berbalut: `{ "data": [ {...} ] }`
class LocalExerciseRepository implements ExerciseRepository {
  LocalExerciseRepository({
    AssetBundle? bundle,
    this.assetPath = 'assets/data/exercises.json',
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String assetPath;

  List<Exercise>? _cache;

  @override
  Future<List<Exercise>> fetchExercises({String? kategori}) async {
    final all = await _loadAll();
    if (kategori == null || kategori.isEmpty) {
      return List<Exercise>.unmodifiable(all);
    }
    final slug = kategori.toLowerCase();
    return List<Exercise>.unmodifiable(
      all.where((exercise) => exercise.kategori.toLowerCase() == slug),
    );
  }

  @override
  Future<Exercise?> fetchExerciseById(String id) async {
    final all = await _loadAll();
    for (final exercise in all) {
      if (exercise.id == id) return exercise;
    }
    return null;
  }

  Future<List<Exercise>> _loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    try {
      final raw = await _bundle.loadString(assetPath);
      final decoded = jsonDecode(raw);

      final List<dynamic> items;
      if (decoded is List) {
        items = decoded;
      } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
        items = decoded['data'] as List<dynamic>;
      } else {
        throw const ExerciseRepositoryException(
          'Format JSON tidak dikenali. Gunakan array atau objek { "data": [...] }.',
        );
      }

      final parsed = items
          .whereType<Map<String, dynamic>>()
          .map(Exercise.fromJson)
          .toList(growable: false);

      return _cache = List<Exercise>.unmodifiable(parsed);
    } on ExerciseRepositoryException {
      rethrow;
    } catch (error) {
      throw ExerciseRepositoryException(
        'Gagal memuat data gerakan dari $assetPath.',
        cause: error,
      );
    }
  }
}
