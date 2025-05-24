class Payment {
  final String bin;
  final String accountNumber;
  final String accountName;
  final int amount;
  final String description;
  final int orderCode;
  final String currency;
  final String paymentLinkId;
  final String status;
  final String checkoutURl;
  final String qrCode;

  const Payment({
    required this.accountName,
    required this.bin,
    required this.accountNumber,
    required this.amount,
    required this.description,
    required this.orderCode,
    required this.currency,
    required this.paymentLinkId,
    required this.status,
    required this.checkoutURl,
    required this.qrCode,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
      'bin': String bin,
      'accountNumber': String accountNumber,
      'accountName': String accountName,
      'amount': int amount,
      'description': String description,
      'orderCode': int orderCode,
      'currency': String currency,
      'paymentLinkId': String paymentLinkId,
      'status': String status,
      'checkoutUrl': String checkoutURl,
      'qrCode': String qrCode,
      } =>
          Payment(
              accountName: accountName,
              bin: bin,
              accountNumber: accountNumber,
              amount: amount,
              description: description,
              orderCode: orderCode,
              currency: currency,
              paymentLinkId: paymentLinkId,
              status: status,
              checkoutURl: checkoutURl,
              qrCode: qrCode),
      _ => throw const FormatException("Failed to load response"),
    };
  }
}

