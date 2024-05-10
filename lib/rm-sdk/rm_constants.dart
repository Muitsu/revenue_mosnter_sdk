enum RmEnvironment {
  sandbox(code: "SANDBOX"),
  production(code: "PRODUCTION");

  final String code;
  const RmEnvironment({required this.code});
}

enum RMPaymentMethod {
  wechat(code: "WECHATPAY_MY"),
  tng(code: "TNG_MY"),
  boost(code: "BOOST_MY"),
  alipay(code: "ALIPAY_CN"),
  grabpay(code: "GRABPAY_MY"),
  mcash(code: "MCASH_MY"),
  razerpay(code: "RAZERPAY_MY"),
  presto(code: "PRESTO_MY"),
  gobiz(code: "GOBIZ_MY"),
  fpx(code: "FPX_MY"),
  ;

  final String code;
  const RMPaymentMethod({required this.code});
}
