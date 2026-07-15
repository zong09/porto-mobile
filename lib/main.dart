import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'src/db/database.dart';
import 'src/state/providers.dart';
import 'src/state/overview_notifier.dart';
import 'src/ui/app_shell.dart';
import 'src/ui/theme/colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // On-device SQLite; drift_flutter resolves the app documents dir via path_provider.
  final db = AppDatabase(driftDatabase(name: 'porto_mobile'));
  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const PortoApp(),
    ),
  );
}

class PortoApp extends StatelessWidget {
  const PortoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Porto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Anuphan',
        scaffoldBackgroundColor: AppColors.bg,
        useMaterial3: true,
      ),
      home: const _AppRoot(),
    );
  }
}

/// Root that refreshes prices/net-worth whenever the app returns to the
/// foreground (`AppLifecycleState.resumed`), then re-renders [AppShell].
class _AppRoot extends ConsumerStatefulWidget {
  const _AppRoot();

  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(overviewProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) => const AppShell();
}
