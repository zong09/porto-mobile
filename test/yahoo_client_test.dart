import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:porto_mobile/src/prices/api_error.dart';
import 'package:porto_mobile/src/prices/yahoo_client.dart';
import 'package:porto_mobile/src/prices/fx_provider.dart';

class MockDio extends Mock implements Dio {}

Response<dynamic> _resp(dynamic data, {int status = 200, Headers? headers}) =>
    Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: status,
      data: data,
      headers: headers,
    );

DioException _dioErr(int status) => DioException(
      requestOptions: RequestOptions(path: ''),
      response: _resp(null, status: status),
    );

Map<String, dynamic> _chart(double price, double prev) => {
      'chart': {
        'result': [
          {
            'meta': {'regularMarketPrice': price, 'chartPreviousClose': prev}
          }
        ]
      }
    };

void main() {
  late MockDio dio;
  setUpAll(() => registerFallbackValue(Options()));
  setUp(() => dio = MockDio());

  test('1. direct stock success', () async {
    when(() => dio.get(any(), options: any(named: 'options')))
        .thenAnswer((_) async => _resp(_chart(100.0, 90.0)));
    final q = await YahooClient(dio).getStockPrice('AAPL');
    expect(q.price, 100.0);
    expect(q.chg, closeTo((100 / 90 - 1) * 100, 0.01));
  });

  test('2. 401 → crumb → retry', () async {
    // direct chart (no crumb) throws 401
    when(() => dio.get(
            any(that: allOf(contains('/v8/finance/chart/'), isNot(contains('crumb=')))),
            options: any(named: 'options')))
        .thenThrow(_dioErr(401));
    // cookie fetch
    when(() => dio.get(any(that: contains('fc.yahoo.com')),
            options: any(named: 'options')))
        .thenAnswer((_) async => _resp('',
            headers: Headers.fromMap({
              'set-cookie': ['A=B; path=/']
            })));
    // crumb fetch
    when(() => dio.get(any(that: contains('getcrumb')),
            options: any(named: 'options')))
        .thenAnswer((_) async => _resp('CR'));
    // retry chart (with crumb) succeeds
    when(() => dio.get(any(that: contains('crumb=')),
            options: any(named: 'options')))
        .thenAnswer((_) async => _resp(_chart(100.0, 90.0)));

    final q = await YahooClient(dio).getStockPrice('AAPL');
    expect(q.price, 100.0);
  });

  test('3. FX from THB=X', () async {
    when(() => dio.get(any(), options: any(named: 'options')))
        .thenAnswer((_) async => _resp(_chart(35.5, 35.5)));
    expect(await YahooClient(dio).getFxRate(), 35.5);
  });

  test('4. FX fallback 35.84 when all fails', () async {
    when(() => dio.get(any(), options: any(named: 'options')))
        .thenThrow(_dioErr(500));
    expect(await YahooClient(dio).getFxRate(), 35.84);
  });

  test('5. .BK passthrough builds correct URL', () async {
    when(() => dio.get(captureAny(), options: any(named: 'options')))
        .thenAnswer((_) async => _resp(_chart(10.0, 10.0)));
    await YahooClient(dio).getStockPrice('PTT.BK');
    final captured = verify(() => dio.get(captureAny(), options: any(named: 'options')))
        .captured;
    expect(captured.any((u) => u.toString().contains('PTT.BK')), isTrue);
  });

  test('6. invalid symbol throws ApiError', () async {
    expect(() => YahooClient(dio).getStockPrice('AA!!'),
        throwsA(isA<ApiError>()));
  });

  test('FxProvider delegates to YahooClient.getFxRate', () async {
    when(() => dio.get(any(), options: any(named: 'options')))
        .thenAnswer((_) async => _resp(_chart(31.0, 31.0)));
    expect(await FxProvider(YahooClient(dio)).call(), 31.0);
  });
}
