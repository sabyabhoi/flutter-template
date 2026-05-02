.PHONY: help bootstrap get gen gen-watch gen-clean format analyze test test-coverage \
	run-dev run-staging run-prod \
	build-apk-dev build-apk-staging build-apk-prod \
	build-ios-dev build-ios-staging build-ios-prod \
	clean

# Default target — list available commands.
help:
	@grep -E '^[a-zA-Z_-]+:.*?#' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?# "}; {printf "  %-22s %s\n", $$1, $$2}'

bootstrap: get gen # Install deps and run codegen.

get: # Install/refresh pub dependencies.
	flutter pub get

gen: # One-shot codegen (freezed, json_serializable, riverpod, drift).
	dart run build_runner build

gen-watch: # Continuous codegen during development.
	dart run build_runner watch

gen-clean: # Wipe + regenerate (use when stale outputs cause weird errors).
	dart run build_runner clean && dart run build_runner build

format: # Format all Dart sources.
	dart format lib test integration_test

analyze: # Static analysis (very_good_analysis + riverpod_lint).
	flutter analyze

test: # Run unit + widget tests.
	flutter test

test-coverage: # Run tests with coverage. Outputs to coverage/lcov.info.
	flutter test --coverage

# Per-flavor run targets. All assume env/<flavor>.json exists; copy from
# env/example.json for the first run.

run-dev: # Run the dev flavor on the connected device.
	flutter run --flavor dev -t lib/main_dev.dart \
		--dart-define-from-file=env/dev.json

run-staging: # Run the staging flavor.
	flutter run --flavor staging -t lib/main_staging.dart \
		--dart-define-from-file=env/staging.json

run-prod: # Run the prod flavor.
	flutter run --flavor prod -t lib/main_prod.dart \
		--dart-define-from-file=env/prod.json

build-apk-dev: # Build a debug APK for the dev flavor.
	flutter build apk --debug --flavor dev -t lib/main_dev.dart \
		--dart-define-from-file=env/dev.json

build-apk-staging: # Build a release APK for the staging flavor.
	flutter build apk --release --flavor staging -t lib/main_staging.dart \
		--dart-define-from-file=env/staging.json

build-apk-prod: # Build a release APK for the prod flavor.
	flutter build apk --release --flavor prod -t lib/main_prod.dart \
		--dart-define-from-file=env/prod.json

build-ios-dev: # Build an iOS app for the dev flavor (requires Xcode wiring; see README).
	flutter build ios --debug --flavor dev -t lib/main_dev.dart \
		--dart-define-from-file=env/dev.json

build-ios-staging: # Build an iOS app for the staging flavor.
	flutter build ios --release --flavor staging -t lib/main_staging.dart \
		--dart-define-from-file=env/staging.json

build-ios-prod: # Build an iOS app for the prod flavor.
	flutter build ios --release --flavor prod -t lib/main_prod.dart \
		--dart-define-from-file=env/prod.json

clean: # Clean Flutter build artefacts.
	flutter clean
