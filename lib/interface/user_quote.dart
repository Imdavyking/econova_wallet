class UserQuote {
  final double quoteAmount;

  UserQuote(this.quoteAmount);

  factory UserQuote.fromJson(Map<String, dynamic> json) {
    return UserQuote(double.parse(json['quoteAmount'].toString()));
  }

  Map<String, dynamic> toJson() {
    return {
      'quoteAmount': quoteAmount,
    };
  }
}
