import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/exercise.dart';
import 'exercise_repository.dart';

/// Implementasi repository berbasis REST API.
///
/// Sudah disiapkan, tetapi belum dipakai secara default. Aktifkan lewat
/// `RepositoryProvider` (lihat `lib/data/repository_provider.dart`) atau
/// jalankan: `flutter run --dart-define=USE_API=true`.
///
/// Kontrak endpoint yang diasumsikan:
///   GET  {baseUrl}/exercises?kategori=punggung  -> { "data": [ ... ] }
///   GET  {baseUrl}/exercises/{id}               -> { "data": { ... } }
class ApiExerciseRepository implements ExerciseRepository {
  ApiExerciseRepository({
    required String baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  })  : baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl,
        _client = client ?? http.Client();

  final String baseUrl;
  final Duration timeout;
  final http.Client _client;

  @override
  Future<List<Exercise>> fetchExercises({String? kategori}) async {
    final uri = Uri.parse('$baseUrl/exercises').replace(
      queryParameters: (kategori == null || kategori.isEmpty)
          ? null
          : <String, String>{'kategori': kategori},
    );

    final decoded = await _getJson(uri);
    final items = _extractList(decoded);
    return List<Exercise>.unmodifiable(
      items.whereType<Map<String, dynamic>>().map(Exercise.fromJson),
    );
  }

  @override
  Future<Exercise?> fetchExerciseById(String id) async {
    final uri = Uri.parse('$baseUrl/exercises/$id');
    final decoded = await _getJson(uri);

    final Map<String, dynamic>? data;
    if (decoded is Map<String, dynamic>) {
      final inner = decoded['data'];
      data = inner is Map<String, dynamic> ? inner : decoded;
    } else {
      data = null;
    }
    return data == null ? null : Exercise.fromJson(data);
  }

  Future<dynamic> _getJson(Uri uri) async {
    try {
      final response = await _client.get(
        uri,
        headers: const <String, String>{'Accept': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 404) return null;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ExerciseRepositoryException(
          'Server mengembalikan status ${response.statusCode}.',
        );
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on ExerciseRepositoryException {
      rethrow;
    } on TimeoutException catch (error) {
      throw ExerciseRepositoryException(
        'Permintaan ke server melebihi batas waktu.',
        cause: error,
      );
    } catch (error) {
      throw ExerciseRepositoryException(
        'Tidak dapat menghubungi server. Periksa koneksi internet.',
        cause: error,
      );
    }
  }

  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic> && decoded['data'] is List) {
      return decoded['data'] as List<dynamic>;
    }
    throw const ExerciseRepositoryException(
      'Respons API tidak sesuai kontrak: daftar data tidak ditemukan.',
    );
  }
}
