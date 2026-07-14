import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/models/enums.dart';
import 'package:porto_mobile/src/models/models.dart';

void main() {
  group('enums', () {
    test('Currency wire/fromWire', () {
      expect(Currency.thb.wire, 'THB');
      expect(Currency.fromWire('USD'), Currency.usd);
    });
    test('AssetType fromWire', () {
      expect(AssetType.fromWire('crypto'), AssetType.crypto);
    });
  });

  group('model JSON round-trips', () {
    test('Asset', () {
      const a = Asset(
        id: 'a',
        portfolioId: 'p',
        type: AssetType.crypto,
        symbol: 'BTC',
        name: 'Bitcoin',
        currency: Currency.usd,
        direction: Direction.short,
        manualPrice: null,
      );
      final json = a.toJson();
      expect(json['type'], 'crypto');
      expect(json['currency'], 'USD');
      expect(json['direction'], 'short');
      expect(Asset.fromJson(json), a);
    });

    test('TransactionModel', () {
      const t = TransactionModel(
        id: 't',
        assetId: 'a',
        side: TxSide.buy,
        quantity: 0.5,
        price: 100,
        fee: 1,
        date: '2026-01-01',
        createdAt: '2026-01-01T00:00:00Z',
      );
      final json = t.toJson();
      expect(json['side'], 'buy');
      expect(TransactionModel.fromJson(json), t);
    });
  });
}
