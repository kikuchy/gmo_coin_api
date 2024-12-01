import 'package:gmo_coin_api/gmo_coin_api.dart';

void main() async {
  final client = GmoCoinPublicAPIClient();

  final status = await client.getStatus();
  print(status.data!);

  final tickers = await client.getTicker(symbol: 'BTC_JPY');
  print(tickers.data!.first.volume);

  final trades = await client.getTrades(
    symbol: 'BTC_JPY',
  );
  print(trades.data!.last.price);

  final klines = await client.getKLines(
    symbol: 'BTC_JPY',
    interval: KLineInterval.min1,
    date: DateTime.now(),
  );
  print(klines.data!.last.openTime);

  final symbols = await client.getSymbols();
  print(symbols.data!.first.symbol);

  client.close();
}
