import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

/// GMOコインのPublic WebSocket APIクライアント
class GmoCoinPublicRealtimeApi {
  static const _wsEndpoint = 'wss://api.coin.z.com/ws/public/v1';

  final WebSocketChannel _channel;
  final StreamController<Map<String, dynamic>> _controller;

  GmoCoinPublicRealtimeApi()
      : _channel = WebSocketChannel.connect(Uri.parse(_wsEndpoint)),
        _controller = StreamController<Map<String, dynamic>>.broadcast() {
// メッセージ受信時の処理
    _channel.stream.listen(
      (message) {
        if (message != null) {
          final data = jsonDecode(message);
          _controller.add(data);
        }
      },
      onError: (error) {
        _controller.addError(error);
        close();
      },
      onDone: () {
        close();
      },
    );
  }

  /// WebSocketストリーム
  Stream<Map<String, dynamic>>? get stream => _controller.stream;

  /// WebSocket接続を終了
  void close() {
    _channel.sink.close();
    _controller.close();
  }

  /// 板情報の購読開始
  Stream<Map<String, dynamic>> subscribeOrderBooks(String symbol) async* {
    await _sendRequest('orderbooks', {'symbol': symbol});
    yield* _controller.stream.where((data) => data['channel'] == 'orderbooks');
  }

  /// 最新レートの購読開始
  Stream<Map<String, dynamic>> subscribeTicker(String symbol) async* {
    await _sendRequest('ticker', {'symbol': symbol});
    yield* _controller.stream.where((data) => data['channel'] == 'ticker');
  }

  /// 取引履歴の購読開始
  Stream<Map<String, dynamic>> subscribeTrades(String symbol) async* {
    await _sendRequest('trades', {'symbol': symbol});
    yield* _controller.stream.where((data) => data['channel'] == 'trades');
  }

  // WebSocketメッセージ送信
  Future<void> _sendRequest(String channel, Map<String, dynamic> params) async {
    await _channel.ready;
    final request = {
      'command': 'subscribe',
      'channel': channel,
      ...params,
    };
    _channel.sink.add(jsonEncode(request));
  }
}
