class KLine {
  final DateTime openTime;
  final int open;
  final int high;
  final int low;
  final int close;
  final double volume;

  KLine.fromJson(Map<String, dynamic> json)
      : openTime = DateTime.fromMillisecondsSinceEpoch(int.parse(json['openTime'] as String)),
        open = int.parse(json['open'] as String),
        high = int.parse(json['high'] as String),
        low = int.parse(json['low'] as String),
        close = int.parse(json['close'] as String),
        volume = double.parse(json['volume'] as String);
}
