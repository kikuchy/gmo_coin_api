import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:gmo_coin_api/src/models/gmo_coin_response.dart';

import 'package:http/http.dart' as http;

/// GMO Coin Private APIクライアント
class GmoCoinPrivateAPIClient {
  static const _baseUrl = 'https://api.coin.z.com/private';
  final http.Client _client;
  final String _apiKey;
  final String _secretKey;

  GmoCoinPrivateAPIClient({
    required String apiKey,
    required String secretKey,
    http.Client? client,
  })  : _apiKey = apiKey,
        _secretKey = secretKey,
        _client = client ?? http.Client();

  /// APIクライアントを閉じます
  void close() {
    _client.close();
  }

  /// 署名を生成します
  String _generateSignature(String timestamp, String method, String path,
      [String? body]) {
    final text = timestamp + method + path + (body ?? '');
    final key = utf8.encode(_secretKey);
    final bytes = utf8.encode(text);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }

  /// 共通のリクエスト処理を行います
  Future<GmoCoinResponse<T>> _request<T>({
    required String path,
    required String method,
    required T Function(dynamic json) fromJson,
    Map<String, dynamic>? queryParameters,
    Object? body,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final signature = _generateSignature(
      timestamp,
      method,
      path,
      body != null ? jsonEncode(body) : null,
    );

    var uri = Uri.parse('$_baseUrl$path');
    if (queryParameters != null) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    final headers = {
      'API-KEY': _apiKey,
      'API-TIMESTAMP': timestamp,
      'API-SIGN': signature,
    };

    if (body != null) {
      headers['Content-Type'] = 'application/json';
    }

    final response = await switch (method) {
      'GET' => _client.get(uri, headers: headers),
      'POST' => _client.post(uri, headers: headers, body: jsonEncode(body)),
      _ => throw Exception('Unsupported HTTP method: $method'),
    };

    if (response.statusCode != 200) {
      throw Exception('Request failed: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return GmoCoinResponse.fromJson(json, fromJson);
  }

  /// 資産残高を取得します
  Future<GmoCoinResponse<List<Balance>>> getAssets() async {
    return _request<List<Balance>>(
      path: '/v1/account/assets',
      method: 'GET',
      fromJson: (data) => (data as List)
          .map((e) => Balance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 取引高情報を取得します
  Future<GmoCoinResponse<TradingVolume>> getTradingVolume() async {
    return _request<TradingVolume>(
      path: '/v1/account/tradingVolume',
      method: 'GET',
      fromJson: (data) => TradingVolume.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 日本円の入金履歴を取得します
  Future<GmoCoinResponse<List<FiatDepositWithdrawalHistory>>>
      getFiatDepositHistory() async {
    return _request<List<FiatDepositWithdrawalHistory>>(
      path: '/v1/account/fiatDeposit/history',
      method: 'GET',
      fromJson: (data) => (data as List)
          .map((e) =>
              FiatDepositWithdrawalHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 日本円の出金履歴を取得します
  Future<GmoCoinResponse<List<FiatDepositWithdrawalHistory>>>
      getFiatWithdrawalHistory() async {
    return _request<List<FiatDepositWithdrawalHistory>>(
      path: '/v1/account/fiatWithdrawal/history',
      method: 'GET',
      fromJson: (data) => (data as List)
          .map((e) =>
              FiatDepositWithdrawalHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 暗号資産の入金履歴を取得します
  Future<GmoCoinResponse<List<CryptoDepositHistory>>> getCryptoDepositHistory(
      {String? symbol}) async {
    return _request<List<CryptoDepositHistory>>(
      path: '/v1/account/cryptoDeposit/history',
      method: 'GET',
      queryParameters: symbol != null ? {'symbol': symbol} : null,
      fromJson: (data) => (data as List)
          .map((e) => CryptoDepositHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 暗号資産の出金履歴を取得します
  Future<GmoCoinResponse<List<CryptoWithdrawalHistory>>>
      getCryptoWithdrawalHistory({String? symbol}) async {
    return _request<List<CryptoWithdrawalHistory>>(
      path: '/v1/account/cryptoWithdrawal/history',
      method: 'GET',
      queryParameters: symbol != null ? {'symbol': symbol} : null,
      fromJson: (data) => (data as List)
          .map((e) =>
              CryptoWithdrawalHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 注文を行います
  Future<GmoCoinResponse<OrderResult>> postOrder({
    required String symbol,
    required String side,
    required String executionType,
    required String timeInForce,
    String? price,
    String? losscutPrice,
    String? size,
  }) async {
    return _request<OrderResult>(
      path: '/v1/order',
      method: 'POST',
      body: {
        'symbol': symbol,
        'side': side,
        'executionType': executionType,
        'timeInForce': timeInForce,
        if (price != null) 'price': price,
        if (losscutPrice != null) 'losscutPrice': losscutPrice,
        if (size != null) 'size': size,
      },
      fromJson: (data) => OrderResult.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 注文をキャンセルします
  Future<GmoCoinResponse<void>> cancelOrder(String orderId) async {
    return _request<void>(
      path: '/v1/order',
      method: 'POST',
      body: {
        'orderId': orderId,
      },
      fromJson: (_) {},
    );
  }

  /// 注文の一覧を取得します
  Future<GmoCoinResponse<List<Order>>> getOrders({
    String? symbol,
    String? orderId,
    String? status,
  }) async {
    return _request<List<Order>>(
      path: '/v1/orders',
      method: 'GET',
      queryParameters: {
        if (symbol != null) 'symbol': symbol,
        if (orderId != null) 'orderId': orderId,
        if (status != null) 'status': status,
      },
      fromJson: (data) => (data as List)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 資産残高情報
class Balance {
  final String symbol;
  final String amount;
  final String available;

  const Balance({
    required this.symbol,
    required this.amount,
    required this.available,
  });

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      symbol: json['symbol'] as String,
      amount: json['amount'] as String,
      available: json['available'] as String,
    );
  }
}

/// 取引高情報
class TradingVolume {
  final String tradingVolume;
  final double makerFee;
  final double takerFee;

  const TradingVolume({
    required this.tradingVolume,
    required this.makerFee,
    required this.takerFee,
  });

  factory TradingVolume.fromJson(Map<String, dynamic> json) {
    return TradingVolume(
      tradingVolume: json['tradingVolume'] as String,
      makerFee: double.parse(json['makerFee'] as String),
      takerFee: double.parse(json['takerFee'] as String),
    );
  }
}

class FiatDepositWithdrawalHistory {
  final int amount;
  final double fee;
  final String status;
  final String symbol;
  final DateTime timestamp;

  const FiatDepositWithdrawalHistory({
    required this.amount,
    required this.fee,
    required this.status,
    required this.symbol,
    required this.timestamp,
  });

  factory FiatDepositWithdrawalHistory.fromJson(Map<String, dynamic> json) {
    return FiatDepositWithdrawalHistory(
      amount: int.parse(json['amount'] as String),
      fee: double.parse(json['fee'] as String),
      status: json['status'] as String,
      symbol: json['symbol'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// 暗号資産の入金履歴
class CryptoDepositHistory {
  final String symbol;
  final String address;
  final String txHash;
  final String amount;
  final DateTime timestamp;
  final String status;

  const CryptoDepositHistory({
    required this.symbol,
    required this.address,
    required this.txHash,
    required this.amount,
    required this.timestamp,
    required this.status,
  });

  factory CryptoDepositHistory.fromJson(Map<String, dynamic> json) {
    return CryptoDepositHistory(
      symbol: json['symbol'] as String,
      address: json['address'] as String,
      txHash: json['txHash'] as String,
      amount: json['amount'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
    );
  }
}

/// 暗号資産の出金履歴
class CryptoWithdrawalHistory {
  final String symbol;
  final String address;
  final String txHash;
  final String amount;
  final double fee;
  final DateTime timestamp;
  final String status;

  const CryptoWithdrawalHistory({
    required this.symbol,
    required this.address,
    required this.txHash,
    required this.amount,
    required this.fee,
    required this.timestamp,
    required this.status,
  });

  factory CryptoWithdrawalHistory.fromJson(Map<String, dynamic> json) {
    return CryptoWithdrawalHistory(
      symbol: json['symbol'] as String,
      address: json['address'] as String,
      txHash: json['txHash'] as String,
      amount: json['amount'] as String,
      fee: double.parse(json['fee'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
    );
  }
}

/// 注文結果
class OrderResult {
  final String orderId;

  const OrderResult({required this.orderId});

  factory OrderResult.fromJson(Map<String, dynamic> json) {
    return OrderResult(orderId: json['orderId'] as String);
  }
}

/// 注文情報
class Order {
  final String orderId;
  final String symbol;
  final String side;
  final String executionType;
  final String? settleType;
  final String size;
  final String? executedSize;
  final String? price;
  final String? losscutPrice;
  final String status;
  final DateTime timestamp;

  const Order({
    required this.orderId,
    required this.symbol,
    required this.side,
    required this.executionType,
    this.settleType,
    required this.size,
    this.executedSize,
    this.price,
    this.losscutPrice,
    required this.status,
    required this.timestamp,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] as String,
      symbol: json['symbol'] as String,
      side: json['side'] as String,
      executionType: json['executionType'] as String,
      settleType: json['settleType'] as String?,
      size: json['size'] as String,
      executedSize: json['executedSize'] as String?,
      price: json['price'] as String?,
      losscutPrice: json['losscutPrice'] as String?,
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
