// Stage B — display-currency formatting (DisplayMoney) + the displayMoneyProvider
// wiring that lets Settings › สกุลเงินหลัก actually reformat values.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:porto_mobile/src/domain/formatters.dart';
import 'package:porto_mobile/src/state/display_money.dart';
import 'package:porto_mobile/src/state/overview_notifier.dart';
import 'package:porto_mobile/src/state/settings_notifier.dart';

void main() {
  group('DisplayMoney', () {
    const fx = 36.0;
    const thb = DisplayMoney.thb;
    const usd = DisplayMoney(currency: 'USD', fx: fx);

    test('THB is a passthrough — fx is ignored', () {
      // Deliberately a nonsense fx: THB→THB must not touch it.
      const weird = DisplayMoney(currency: 'THB', fx: 999);
      expect(weird.money(1234.5), '1,234.50');
      expect(thb.money(1234.5), '1,234.50');
      expect(thb.convert(3600), 3600);
    });

    test('USD divides by fx', () {
      expect(usd.convert(3600), 100);
      expect(usd.money(3600), '100.00');
    });

    test('symbol and label follow the currency', () {
      expect(thb.symbol, '฿');
      expect(thb.label, '฿ THB');
      expect(usd.symbol, r'$');
      expect(usd.label, r'$ USD');
    });

    test('compact converts before abbreviating', () {
      // 36,000,000 THB / 36 == 1,000,000 USD → '1.0M', not '36.0M'.
      expect(thb.compact(36000000), '36.0M');
      expect(usd.compact(36000000), '1.0M');
      // below 1000 falls through to 2dp
      expect(usd.compact(3600), '100.00');
    });

    test('negatives keep their sign', () {
      expect(usd.money(-3600), '-100.00');
      expect(thb.money(-12.3), '-12.30');
    });
  });

  group('displayMoneyProvider', () {
    ProviderContainer containerFor(String currency, {double fx = 36.0}) =>
        ProviderContainer(overrides: [
          settingsProvider.overrideWith(() => _StubSettings(currency)),
          fxProvider.overrideWithValue(() async => fx),
        ]);

    test('resolves the persisted display currency', () async {
      final c = containerFor('USD');
      addTearDown(c.dispose);

      final money = await c.read(displayMoneyProvider.future);
      expect(money.currency, 'USD');
      expect(money.fx, 36.0);
      expect(money.money(3600), '100.00');
    });

    test('resolves fx even when displaying THB — native sums need it', () async {
      final c = containerFor('THB');
      addTearDown(c.dispose);

      final money = await c.read(displayMoneyProvider.future);
      expect(money.currency, 'THB');
      // The real rate, NOT the fx=1 of DisplayMoney.thb: screens use this to
      // normalise USD liabilities/transactions into THB before summing.
      expect(money.fx, 36.0);
    });
  });
}

class _StubSettings extends SettingsNotifier {
  _StubSettings(this.currency);
  final String currency;

  @override
  Future<SettingsState> build() async =>
      SettingsState(displayCurrency: currency, language: 'th');
}
