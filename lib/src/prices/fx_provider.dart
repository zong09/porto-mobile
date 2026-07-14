import 'yahoo_client.dart';

/// Thin glue producing the `getFx` callback that BinanceClient / PriceHistoryClient need.
/// (No Riverpod in Phase 1 — riverpod_generator is deferred. Plain class only.)
class FxProvider {
  final YahooClient yahoo;
  FxProvider(this.yahoo);

  Future<double> call() => yahoo.getFxRate();
}
