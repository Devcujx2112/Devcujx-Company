class PaymentStatusResponse {
  late int error;
  late String message;
  dynamic data;
  PaymentStatusResponse(this.error, this.message, this.data);
  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
      'error': int error,
      'message': String message,
      'data': dynamic data,
      } =>
          PaymentStatusResponse(error, message, data),
      _ => throw ArgumentError("Fail to convert"),
    };
  }
}
