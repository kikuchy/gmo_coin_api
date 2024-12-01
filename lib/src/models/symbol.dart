class Symbol {
  final String symbol;
  final double minOrderSize;
  final double maxOrderSize;
  final double sizeStep;
  final double tickSize;
  final double takerFee;
  final double makerFee;

  Symbol.fromJson(Map<String, dynamic> json)
      : symbol = json['symbol'] as String,
        minOrderSize = double.parse(json['minOrderSize'] as String),
        maxOrderSize = double.parse(json['maxOrderSize'] as String),
        sizeStep = double.parse(json['sizeStep'] as String),
        tickSize = double.parse(json['tickSize'] as String),
        takerFee = double.parse(json['takerFee'] as String),
        makerFee = double.parse(json['makerFee'] as String);
}
