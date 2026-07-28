// T4.2 — end-to-end smoke flow, ON-DEVICE entry point.
//
// ⚠️ NEVER EXECUTED IN THIS REPO'S ENVIRONMENT. There is no emulator and no
// adb here, and the project has only `android`+`ios` platform dirs, so
// `flutter test integration_test/` fails with "No supported devices". This file
// is analyze-clean but UNVERIFIED AT RUNTIME — treat the first real run as the
// actual test of it.
//
// On a connected device or emulator:
//
//   flutter test integration_test/app_test.dart
//
// The flow body is shared with `test/smoke_test.dart` (which does run headless
// on every `flutter test`), so the two cannot drift apart — only the binding
// differs. If this fails on-device while the headless run passes, suspect the
// environment (sqlite3 native libs, temp-dir permissions), not the flow.

import 'package:integration_test/integration_test.dart';

import '../test/smoke_flow.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  runSmokeFlow();
}
