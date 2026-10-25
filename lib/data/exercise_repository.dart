import '../models/exercise.dart';

/// Kontrak sumber data gerakan.
///
/// Halaman (UI) hanya bergantung pada antarmuka ini, sehingga sumber data
/// bisa diganti dari JSON lokal ke REST API tanpa mengubah widget.
abstract class ExerciseRepository {
  /// Mengambil daftar gerakan. [kategori] opsional (slug, mis. "punggung").
  Future<List<Exercise>> fetchExercises({String? kategori});

  /// Mengambil satu gerakan berdasarkan id. Null bila tidak ditemukan.
  Future<Exercise?> fetchExerciseById(String id);
}

/// Error terpadu agar UI bisa menampilkan pesan yang ramah pengguna.
class ExerciseRepositoryException implements Exception {
  const ExerciseRepositoryException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'ExerciseRepositoryException: $message';
}
