import 'package:dio/dio.dart';
import 'api_error.dart';

const _ua =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
final _symbolRegex = RegExp(r'^[A-Za-z0-9.\-^=]{1,15}$');

class PricePoint {
  final int t; // epoch ms
  final double p; // price
  const PricePoint(this.t, this.p);
}

/// Chart-history client ported from `prices.service.ts`
/// (getCryptoHistory / getStockHistory). CONTRACTS §5.
///
/// Note (accepted Phase-1 simplification): stockHistory does a single direct
/// Yahoo request (no crumb retry); crumb handling lives in YahooClient (T1.12).
class PriceHistoryClient {
  final Dio dio;
  final Future<double> Function() getFx;
  PriceHistoryClient(this.dio, {required this.getFx});

  static final _opts = Options(validateStatus: (_) => true);

  Future<List<PricePoint>> cryptoHistory(String coinId, int days) async {
    if (!_symbolRegex.hasMatch(coinId)) throw ApiError('invalid symbol: $coinId');

    if (coinId == 'USDT') {
      final fx = await getFx();
      final now = DateTime.now().millisecondsSinceEpoch;
      return [PricePoint(now - 86400000 * days, fx), PricePoint(now, fx)];
    }

    final String interval;
    final int limit;
    if (days <= 1) {
      interval = '5m';
      limit = 288;
    } else if (days <= 7) {
      interval = '1h';
      limit = 168;
    } else if (days <= 90) {
      interval = '1d';
      limit = days;
    } else {
      interval = '1w';
      limit = (days / 7).ceil();
    }

    final url =
        'https://api.binance.com/api/v3/klines?symbol=${Uri.encodeComponent('${coinId}USDT')}&interval=$interval&limit=$limit';
    final resp = await dio.get(url, options: _opts);
    if (resp.statusCode != 200) throw ApiError('crypto history $coinId');
    final fx = await getFx();
    return [
      for (final k in (resp.data as List))
        PricePoint((k[0] as num).toInt(), double.parse(k[4].toString()) * fx),
    ];
  }

  Future<List<PricePoint>> stockHistory(String symbol, String range) async {
    if (!_symbolRegex.hasMatch(symbol)) throw ApiError('invalid symbol: $symbol');
    final interval = range == '1Y' ? '1wk' : '1d';
    final mappedRange = const {
          '7D': '7d',
          '1M': '1mo',
          '3M': '3mo',
          '1Y': '1y',
        }[range] ??
        '3mo';

    final url =
        'https://query1.finance.yahoo.com/v8/finance/chart/${Uri.encodeComponent(symbol)}?range=$mappedRange&interval=$interval';
    final resp = await dio.get(url,
        options: Options(headers: {'User-Agent': _ua}, validateStatus: (_) => true));
    if (resp.statusCode != 200) throw ApiError('stock history $symbol');

    final res = resp.data['chart']?['result']?[0];
    final ts = res?['timestamp'] as List?;
    final cl = res?['indicators']?['quote']?[0]?['close'] as List?;
    final out = <PricePoint>[];
    if (ts != null && cl != null) {
      for (var i = 0; i < ts.length; i++) {
        if (cl[i] != null) {
          out.add(PricePoint((ts[i] as num).toInt() * 1000, (cl[i] as num).toDouble()));
        }
      }
    }
    return out;
  }
}
