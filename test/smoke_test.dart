// T4.2 — end-to-end smoke flow, headless entry point.
//
// The flow itself lives in `smoke_flow.dart` so this and the on-device
// `integration_test/app_test.dart` run the exact same body. Run with:
//
//   flutter test test/smoke_test.dart

import 'smoke_flow.dart';

void main() => runSmokeFlow();
