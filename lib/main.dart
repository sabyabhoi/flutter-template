// Intentionally NOT an entrypoint.
//
// Use one of the per-flavor entrypoints together with the matching env
// file and native flavor:
//
//   flutter run --flavor dev      -t lib/main_dev.dart      \
//     --dart-define-from-file=env/dev.json
//   flutter run --flavor staging  -t lib/main_staging.dart  \
//     --dart-define-from-file=env/staging.json
//   flutter run --flavor prod     -t lib/main_prod.dart     \
//     --dart-define-from-file=env/prod.json
//
// See README.md → "Running" for details.
void main() {
  throw UnsupportedError(
    'lib/main.dart is not an entrypoint — run main_dev.dart, '
    'main_staging.dart, or main_prod.dart with the matching --flavor and '
    '--dart-define-from-file. See README.md.',
  );
}
