import 'dart:convert';
import 'package:gmo_coin_api/src/models/gmo_coin_response.dart';
import 'package:gmo_coin_api/src/models/kline.dart';
import 'package:gmo_coin_api/src/models/orderbook.dart';
import 'package:gmo_coin_api/src/models/ticker.dart';
import 'package:gmo_coin_api/src/models/trade.dart';
import 'package:gmo_coin_api/src/models/symbol.dart';
import 'package:http/http.dart' as http;

/// GMO Coinの取引所ステータス
enum ExchangeStatus {
  /// メンテナンス中
  maintenance,

  /// 取引前
  preopen,

  /// 取引中
  open,

  /// 不明なステータス
  unknown;

  factory ExchangeStatus.fromString(String status) {
    switch (status.toUpperCase()) {
      case 'MAINTENANCE':
        return ExchangeStatus.maintenance;
      case 'PREOPEN':
        return ExchangeStatus.preopen;
      case 'OPEN':
        return ExchangeStatus.open;
      default:
        return ExchangeStatus.unknown;
    }
  }
}

/// GMO Coin APIクライアント
class GmoCoinPublicAPIClient {
  static const _baseUrl = 'https://api.coin.z.com';
  final http.Client _client;

  GmoCoinPublicAPIClient({http.Client? client}) : _client = client ?? http.Client();

  /// 取引所のステータスを取得します
  Future<GmoCoinResponse<ExchangeStatus>> getStatus() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/public/v1/status'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get status: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return GmoCoinResponse.fromJson(
      json,
      (data) => ExchangeStatus.fromString(data['status'] as String),
    );
  }

  /// APIクライアントを閉じます
  void close() {
    _client.close();
  }

  /// 指定した銘柄の最新レート情報を取得します
  Future<GmoCoinResponse<List<Ticker>>> getTicker({String? symbol}) async {
    var uri = Uri.parse('$_baseUrl/public/v1/ticker');
    if (symbol != null) {
      uri = uri.replace(queryParameters: {'symbol': symbol});
    }
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to get ticker: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return GmoCoinResponse.fromJson(
      json,
      (data) => (data as List<dynamic>)
          .map((e) => Ticker.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 指定した銘柄の板情報を取得します
  Future<GmoCoinResponse<OrderBook>> getOrderBook(String symbol) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/public/v1/orderbooks?symbol=$symbol'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get orderbook: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return GmoCoinResponse.fromJson(
      json,
      (data) => OrderBook.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 指定した銘柄の取引履歴を取得します
  Future<GmoCoinResponse<List<Trade>>> getTrades({
    required  symbol,
    int? page,
    int? count,
  }) async {
    var uri = Uri.parse('$_baseUrl/public/v1/trades?symbol=$symbol');
    if (page != null) {
      uri = uri.replace(queryParameters: {'page': page.toString()});
    }
    if (count != null) {
      uri = uri.replace(queryParameters: {'count': count.toString()});
    }
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to get trades: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return GmoCoinResponse.fromJson(
      json,
      (data) => (data['list'] as List)
          .map((e) => Trade.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 指定した銘柄の四本値と取引量（開始時刻の昇順）を取得します
  Future<GmoCoinResponse<List<KLine>>> getKLines({
    required String symbol,
    required KLineInterval interval,
    required DateTime date,
  }) async {
    final intervalString = switch (interval) {
      KLineInterval.min1 => '1min',
      KLineInterval.min5 => '5min',
      KLineInterval.min10 => '10min',
      KLineInterval.min15 => '15min',
      KLineInterval.min30 => '30min',
      KLineInterval.hour1 => '1hour',
      KLineInterval.hour4 => '4hour',
      KLineInterval.hour8 => '8hour',
      KLineInterval.hour12 => '12hour',
      KLineInterval.day1 => '1day',
      KLineInterval.week1 => '1week',
      KLineInterval.month1 => '1month',
    };
    final dateString = switch (interval) {
      KLineInterval.min1 ||
      KLineInterval.min5 ||
      KLineInterval.min10 ||
      KLineInterval.min15 ||
      KLineInterval.min30 ||
      KLineInterval.hour1 =>
        '${date.year.toString().padLeft(4, '0')}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}',
      KLineInterval.hour4 ||
      KLineInterval.hour8 ||
      KLineInterval.hour12 ||
      KLineInterval.day1 ||
      KLineInterval.week1 ||
      KLineInterval.month1 =>
        date.year.toString().padLeft(4, '0'),
    };
    final response = await _client.get(
      Uri.parse(
          '$_baseUrl/public/v1/klines?symbol=$symbol&interval=$intervalString&date=$dateString'),
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return GmoCoinResponse.fromJson(
      json,
      (data) => (data as List)
          .map((e) => KLine.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 取引銘柄を取得します
  Future<GmoCoinResponse<List<Symbol>>> getSymbols() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/public/v1/symbols'),
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return GmoCoinResponse.fromJson(
      json,
      (data) => (data as List)
          .map((e) => Symbol.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

enum KLineInterval {
  /// 1分
  min1,

  /// 5分
  min5,

  /// 10分
  min10,

  /// 15分
  min15,

  /// 30分
  min30,

  /// 1時間
  hour1,

  /// 4時間
  hour4,

  /// 8時間
  hour8,

  /// 12時間
  hour12,

  /// 1日
  day1,

  /// 1週間
  week1,

  /// 1ヶ月
  month1,
}
