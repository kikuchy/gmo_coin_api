/// 最新レート情報
class Ticker {
  final String symbol;
  final DateTime timestamp;
  final double bid;
  final double ask;
  final double high;
  final double low;
  final double volume;
  final double lastPrice;

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
      timestamp: DateTime.parse(json['timestamp'] as String),
      bid: double.parse(json['bid'] as String),
      ask: double.parse(json['ask'] as String),
      high: double.parse(json['high'] as String),
      low: double.parse(json['low'] as String),
      volume: double.parse(json['volume'] as String),
      lastPrice: double.parse(json['last'] as String),
    );
  }
} 