import 'package:dio/dio.dart';
import 'api_error.dart';

const _ua =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
final _symbolRegex = RegExp(r'^[A-Za-z0-9.\-^=]{1,15}$');

class StockQuote {
  final double price, chg; // chg = percent
  const StockQuote({required this.price, required this.chg});
}

/// Stock quote + FX client ported from `prices.service.ts`
/// (getStockPrice / getFxRate / fetchYahooChart / crumb refresh). CONTRACTS §5.
class YahooClient {
  final Dio dio;
  YahooClient(this.dio);

  String? _cookie;
  String? _crumb;

  Future<StockQuote> getStockPrice(String symbol) async {
    if (!_symbolRegex.hasMatch(symbol)) {
      throw ApiError('invalid symbol: $symbol');
    }
    final data = await _fetchYahooChart(symbol, '1d', '1d');
    if (data != null) {
      final meta = data['chart']?['result']?[0]?['meta'];
      if (meta != null && meta['regularMarketPrice'] != null) {
        final price = (meta['regularMarketPrice'] as num).toDouble();
        final prev = ((meta['chartPreviousClose'] ??
                meta['previousClose'] ??
                meta['regularMarketPrice']) as num)
            .toDouble();
        final chg = prev != 0 ? (price / prev - 1) * 100 : 0.0;
        return StockQuote(price: price, chg: chg);
      }
    }
    throw ApiError('Failed to fetch stock price for $symbol');
  }

  Future<double> getFxRate() async {
    try {
      return (await getStockPrice('THB=X')).price;
    } catch (_) {
      return 35.84;
    }
  }

  Future<Map<String, dynamic>?> _fetchYahooChart(
      String symbol, String range, String interval) async {
    try {
      final r = await _doYahooRequest(symbol, range, interval);
      if (r != null) return r;
    } catch (_) {
      // fall through to crumb path
    }
    try {
      if (_crumb == null) await _refreshCredentials();
      if (_crumb != null) {
        final r = await _doYahooRequest(symbol, range, interval,
            crumb: _crumb, cookie: _cookie);
        if (r != null) return r;
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  Future<Map<String, dynamic>?> _doYahooRequest(
      String symbol, String range, String interval,
      {String? crumb, String? cookie}) async {
    var url =
        'https://query1.finance.yahoo.com/v8/finance/chart/${Uri.encodeComponent(symbol)}?range=$range&interval=$interval';
    if (crumb != null) url += '&crumb=${Uri.encodeComponent(crumb)}';
    final headers = <String, String>{'User-Agent': _ua};
    if (cookie != null) headers['Cookie'] = cookie;
    final resp = await dio.get(url, options: Options(headers: headers));
    return resp.data as Map<String, dynamic>?;
  }

  Future<void> _refreshCredentials() async {
    try {
      final fc = await dio.get(
        'https://fc.yahoo.com',
        options: Options(headers: {'User-Agent': _ua}, validateStatus: (_) => true),
      );
      final setCookie = fc.headers.map['set-cookie'];
      if (setCookie != null && setCookie.isNotEmpty) {
        _cookie = setCookie.first.split(';').first;
      }
      final crumbHeaders = <String, String>{'User-Agent': _ua};
      if (_cookie != null) crumbHeaders['Cookie'] = _cookie!;
      final ch = await dio.get(
        'https://query2.finance.yahoo.com/v1/test/getcrumb',
        options: Options(
          headers: crumbHeaders,
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      );
      if (ch.statusCode == 200) _crumb = ch.data as String;
    } catch (_) {
      // ignore
    }
  }
}
