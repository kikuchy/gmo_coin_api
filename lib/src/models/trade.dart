/// 取引履歴
class Trade {
  final String timestamp;
  final String side;
  final String price;
  final String size;

  const Trade({
    required this.timestamp,
    required this.side,
    required this.price,
    required this.size,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      timestamp: json['timestamp'] as String,
      side: json['side'] as String,
      price: json['price'] as String,
      size: json['size'] as String,
    );
  }
}
