import 'package:dio/dio.dart';
import 'api_error.dart';

final _symbolRegex = RegExp(r'^[A-Za-z0-9.\-^=]{1,15}$');

class CryptoPrice {
  final double usd, usdChg, thb, thbChg;
  const CryptoPrice({
    required this.usd,
    required this.usdChg,
    required this.thb,
    required this.thbChg,
  });
}

/// Crypto price client ported from `prices.service.ts#getCryptoPrices`.
/// batch → per-symbol → optional Yahoo fallback → USDT-manual chain (CONTRACTS §5).
class BinanceClient {
  final Dio dio;
  final Future<double> Function() getFx;

  /// Approved extension of CONTRACTS §5: optional Yahoo fallback for symbols not
  /// found on Binance, injected as a callback to avoid importing YahooClient.
  final Future<({double price, double chg})?> Function(String yahooSymbol)?
      yahooFallback;

  BinanceClient(this.dio, {required this.getFx, this.yahooFallback});

  static final _opts = Options(validateStatus: (_) => true);

  Future<Map<String, CryptoPrice>> getPrices(List<String> ids) async {
    final fx = await getFx();
    final result = <String, CryptoPrice>{};
    final failedIds = <String>[];
    final binanceIds = ids.where((id) => id != 'USDT').toList();

    for (final id in binanceIds) {
      if (!_symbolRegex.hasMatch(id)) throw ApiError('invalid symbol: $id');
    }

    if (binanceIds.isNotEmpty) {
      final querySymbols =
          '[${binanceIds.map((id) => '"${id}USDT"').join(',')}]';
      final url =
          'https://api.binance.com/api/v3/ticker/24hr?symbols=${Uri.encodeComponent(querySymbols)}';
      final resp = await dio.get(url, options: _opts);
      if (resp.statusCode == 200 && resp.data is List) {
        for (final item in (resp.data as List)) {
          final sym = item['symbol'] as String;
          final id = sym.endsWith('USDT')
              ? sym.substring(0, sym.length - 4)
              : sym;
          final usd = double.parse(item['lastPrice'].toString());
          final chg = double.parse(item['priceChangePercent'].toString());
          result[id] = CryptoPrice(usd: usd, usdChg: chg, thb: usd * fx, thbChg: chg);
        }
        for (final id in binanceIds) {
          if (!result.containsKey(id)) failedIds.add(id);
        }
      } else {
        // batch failed → per-symbol
        for (final id in binanceIds) {
          try {
            final single = await dio.get(
              'https://api.binance.com/api/v3/ticker/24hr?symbol=${Uri.encodeComponent('${id}USDT')}',
              options: _opts,
            );
            if (single.statusCode == 200) {
              final usd = double.parse(single.data['lastPrice'].toString());
              final chg =
                  double.parse(single.data['priceChangePercent'].toString());
              result[id] =
                  CryptoPrice(usd: usd, usdChg: chg, thb: usd * fx, thbChg: chg);
            } else {
              failedIds.add(id);
            }
          } catch (_) {
            failedIds.add(id);
          }
        }
      }
    }

    // Yahoo fallback (only if callback provided)
    for (final id in failedIds) {
      final fallback = yahooFallback;
      if (fallback != null) {
        try {
          final y = await fallback('$id-USD');
          if (y != null) {
            result[id] = CryptoPrice(
                usd: y.price, usdChg: y.chg, thb: y.price * fx, thbChg: y.chg);
          }
        } catch (_) {
          // ignore
        }
      }
    }

    // USDT manual
    for (final id in ids) {
      if (!result.containsKey(id) && id == 'USDT') {
        result['USDT'] =
            CryptoPrice(usd: 1, usdChg: 0, thb: fx, thbChg: 0);
      }
    }

    return result;
  }
}
