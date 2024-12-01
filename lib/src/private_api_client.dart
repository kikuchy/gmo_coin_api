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
  String _generateSignature(String timestamp, String method, String path, [String? body]) {
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
  Future<GmoCoinResponse<List<Balance>>> getBalances() async {
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