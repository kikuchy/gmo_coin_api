/// GMO Coin APIのレスポンス
class GmoCoinResponse<T> {
  final int status;
  final T? data;
  final List<Map<String, dynamic>>? messages;

  const GmoCoinResponse({
    required this.status,
    this.data,
    this.messages,
  });

  factory GmoCoinResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJson,
  ) {
    return GmoCoinResponse(
      status: json['status'] as int,
      data: json['data'] != null ? fromJson(json['data']) : null,
      messages: (json['messages'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }
}
