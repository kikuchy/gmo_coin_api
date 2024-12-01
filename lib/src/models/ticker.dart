/// 最新レート情報
class Ticker {
  final String symbol;
  final String timestamp;
  final String bid;
  final String ask;
  final String high;
  final String low;
  final String volume;
  final String lastPrice;

  const Ticker({
    required this.symbol,
    required this.timestamp,
    required this.bid,
    required this.ask,
    required this.high,
    required this.low,
    required this.volume,
    required this.lastPrice,
  });

  factory Ticker.fromJson(Map<String, dynamic> json) {
    return Ticker(
      symbol: json['symbol'] as String,
      timestamp: json['timestamp'] as String,
      bid: json['bid'] as String,
      ask: json['ask'] as String,
      high: json['high'] as String,
      low: json['low'] as String,
      volume: json['volume'] as String,
      lastPrice: json['last'] as String,
    );
  }
} 