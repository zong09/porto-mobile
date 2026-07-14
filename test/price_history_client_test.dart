import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:porto_mobile/src/prices/api_error.dart';
import 'package:porto_mobile/src/prices/price_history_client.dart';

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

  test('1. cryptoHistory parses klines to THB points', () async {
    when(() => dio.get(any(), options: any(named: 'options'))).thenAnswer(
      (_) async => _resp([
        [1000, '0', '0', '0', '2350000', '0'],
        [2000, '0', '0', '0', '2360000', '0'],
      ]),
    );
    final c = PriceHistoryClient(dio, getFx: () async => 30);
    final r = await c.cryptoHistory('BTC', 30);
    expect(r.length, 2);
    expect(r[0].t, 1000);
    expect(r[0].p, closeTo(2350000 * 30, 0.01));
    expect(r[1].t, 2000);
    expect(r[1].p, closeTo(2360000 * 30, 0.01));
  });

  test('2. cryptoHistory USDT returns two flat fx points', () async {
    final c = PriceHistoryClient(dio, getFx: () async => 30);
    final r = await c.cryptoHistory('USDT', 7);
    expect(r.length, 2);
    expect(r[0].p, 30.0);
    expect(r[1].p, 30.0);
  });

  test('3. stockHistory skips null closes', () async {
    when(() => dio.get(any(), options: any(named: 'options'))).thenAnswer(
      (_) async => _resp({
        'chart': {
          'result': [
            {
              'timestamp': [1, 2, 3],
              'indicators': {
                'quote': [
                  {
                    'close': [10.0, null, 12.0]
                  }
                ]
              }
            }
          ]
        }
      }),
    );
    final c = PriceHistoryClient(dio, getFx: () async => 30);
    final r = await c.stockHistory('AAPL', '1M');
    expect(r.length, 2);
    expect(r[0].t, 1000);
    expect(r[0].p, 10.0);
    expect(r[1].t, 3000);
    expect(r[1].p, 12.0);
  });

  test('4. non-200 throws ApiError', () async {
    when(() => dio.get(any(), options: any(named: 'options')))
        .thenAnswer((_) async => _resp(null, status: 500));
    final c = PriceHistoryClient(dio, getFx: () async => 30);
    expect(() => c.cryptoHistory('BTC', 30), throwsA(isA<ApiError>()));
  });
}
