import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';
import 'package:porto_mobile/src/state/overview_notifier.dart';
import 'package:porto_mobile/src/state/providers.dart';
import 'package:porto_mobile/src/state/ui_state.dart';
import 'package:porto_mobile/src/ui/app_shell.dart';
import 'package:porto_mobile/src/ui/widgets/app_bottom_nav.dart';

void main() {
  testWidgets('a filter request brings the Transactions tab forward',
      (tester) async {
    // The other half of the Realized P/L banner: the banner writes the filter
    // and pops, and the shell has to react. Asserting on the IndexedStack
    // index rather than on which screen is found — the stack mounts all four
    // children on every tab, so `find.byType(TransactionsScreen)` always hits.
    tester.view.physicalSize = const Size(2400, 3600); // 800x1200 logical
    addTearDown(tester.view.resetPhysicalSize);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      // displayMoneyProvider awaits this — pin it so no test hits the network.
      fxProvider.overrideWithValue(() async => 35.0),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: AppShell()),
    ));
    await tester.pumpAndSettle();

    IndexedStack stack() =>
        tester.widget<IndexedStack>(find.byType(IndexedStack));
    expect(stack().index, 0);

    container.read(txFilterProvider.notifier).choose('sell');
    await tester.pumpAndSettle();

    expect(stack().index, 2);

    // Navigation is a one-shot event riding on the filter, so requesting a
    // filter the provider ALREADY holds still has to move the tab. Leave the
    // tab the way a user does, then tap the banner a second time.
    tester.widget<AppBottomNav>(find.byType(AppBottomNav)).onTap(1);
    await tester.pumpAndSettle();
    expect(stack().index, 1);

    container.read(txFilterProvider.notifier).choose('sell');
    await tester.pumpAndSettle();

    expect(stack().index, 2,
        reason: 'the banner worked once and then silently did nothing');
  });
}
