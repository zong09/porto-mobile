import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:porto_mobile/src/prices/api_error.dart';
import 'package:porto_mobile/src/prices/binance_client.dart';

class MockDio extends Mock implements Dio {}

Response<dynamic> _resp(dynamic data, {int status = 200}) => Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: status,
      data: data,
    );

void main() {
  late MockDio dio;

  setUpAll(() => registerFallbackValue(Options()));
  setUp(() => dio = MockDio());

  test('1. batch success', () async {
    when(() => dio.get(any(), options: any(named: 'options'))).thenAnswer(
      (_) async => _resp([
        {'symbol': 'BTCUSDT', 'lastPrice': '2350000', 'priceChangePercent': '1.5'},
        {'symbol': 'ETHUSDT', 'lastPrice': '120000', 'priceChangePercent': '-2.0'},
      ]),
    );
    final c = BinanceClient(dio, getFx: () async => 30);
    final r = await c.getPrices(['BTC', 'ETH']);
    expect(r['BTC']!.usd, 2350000);
    expect(r['BTC']!.usdChg, 1.5);
    expect(r['BTC']!.thb, closeTo(2350000 * 30, 0.01));
    expect(r['BTC']!.thbChg, 1.5);
    expect(r['ETH']!.usd, 120000);
    expect(r['ETH']!.usdChg, -2.0);
  });

  test('2. batch fails → per-symbol', () async {
    when(() => dio.get(any(that: contains('symbols=')),
        options: any(named: 'options'))).thenAnswer((_) async => _resp(null, status: 400));
    when(() => dio.get(
        any(that: allOf(contains('symbol='), isNot(contains('symbols=')))),
        options: any(named: 'options'))).thenAnswer((_) async => _resp(
        {'symbol': 'BTCUSDT', 'lastPrice': '100', 'priceChangePercent': '0'}));
    final c = BinanceClient(dio, getFx: () async => 30);
    final r = await c.getPrices(['BTC']);
    expect(r['BTC']!.usd, 100);
  });

  test('3. Yahoo fallback for failed symbol', () async {
    when(() => dio.get(any(), options: any(named: 'options')))
        .thenAnswer((_) async => _resp([])); // empty batch → BTC failed
    final c = BinanceClient(
      dio,
      getFx: () async => 30,
      yahooFallback: (s) async => (price: 5.0, chg: 1.0),
    );
    final r = await c.getPrices(['BTC']);
    expect(r['BTC']!.usd, 5.0);
    expect(r['BTC']!.thb, closeTo(5 * 30, 0.01));
  });

  test('4. USDT manual', () async {
    final c = BinanceClient(dio, getFx: () async => 30);
    final r = await c.getPrices(['USDT']);
    expect(r['USDT']!.usd, 1);
    expect(r['USDT']!.usdChg, 0);
    expect(r['USDT']!.thb, 30);
  });

  test('5. invalid symbol throws ApiError', () async {
    final c = BinanceClient(dio, getFx: () async => 30);
    expect(() => c.getPrices(['BTC!!']), throwsA(isA<ApiError>()));
  });
}
