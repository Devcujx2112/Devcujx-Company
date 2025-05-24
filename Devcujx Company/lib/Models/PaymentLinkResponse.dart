class DeepLinkItemResponse {
  late String appId;
  late String appLogo;
  late String appName;
  late String bankName;
  late int monthlyInstall;
  late String? deepLink;
  late int autofill;

  DeepLinkItemResponse(this.appId, this.appLogo, this.appName, this.bankName,
      this.monthlyInstall, this.deepLink, this.autofill);
  factory DeepLinkItemResponse.fromJson(Map<String, dynamic> json) {
    return DeepLinkItemResponse(
      json['appId'] as String,
      json['appLogo'] as String,
      json['appName'] as String,
      json['bankName'] as String,
      json['monthlyInstall'] as int,
      json['deepLink'] as String?,
      json['autofill'] as int,
    );
  }
}
