import 'api_exercise_repository.dart';
import 'exercise_repository.dart';
import 'local_exercise_repository.dart';

/// Titik tunggal untuk memilih sumber data.
///
/// Default: JSON lokal. Untuk beralih ke API tanpa mengubah halaman:
///   flutter run --dart-define=USE_API=true ^
///               --dart-define=API_BASE_URL=https://domain-kamu/api/v1
class RepositoryProvider {
  const RepositoryProvider._();

  static const bool useApi =
      bool.fromEnvironment('USE_API', defaultValue: false);

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com/v1',
  );

  static ExerciseRepository get exerciseRepository => useApi
      ? ApiExerciseRepository(baseUrl: apiBaseUrl)
      : LocalExerciseRepository();
}
