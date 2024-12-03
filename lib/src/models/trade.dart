/// 取引履歴
class Trade {
  final DateTime timestamp;
  final TradeSide side;
  final double price;
  final double size;

  const Trade({
    required this.timestamp,
    required this.side,
    required this.price,
    required this.size,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      timestamp: DateTime.parse(json['timestamp'] as String),
      side: TradeSide.values.firstWhere((e) => e.name == json['side']),
      price: double.parse(json['price'] as String),
      size: double.parse(json['size'] as String),
    );
  }
}

enum TradeSide {
  buy,
  sell,
}
