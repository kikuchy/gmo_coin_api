/// 板情報のエントリー
class OrderBookEntry {
  final String price;
  final String size;

  const OrderBookEntry({
    required this.price,
    required this.size,
  });

  factory OrderBookEntry.fromJson(Map<String, dynamic> json) {
    return OrderBookEntry(
      price: json['price'] as String,
      size: json['size'] as String,
    );
  }
}

/// 板情報
class OrderBook {
  final String symbol;
  final List<OrderBookEntry> asks;
  final List<OrderBookEntry> bids;

  const OrderBook({
    required this.symbol,
    required this.asks,
    required this.bids,
  });

  factory OrderBook.fromJson(Map<String, dynamic> json) {
    return OrderBook(
      symbol: json['symbol'] as String,
      asks: (json['asks'] as List)
          .map((e) => OrderBookEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      bids: (json['bids'] as List)
          .map((e) => OrderBookEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
