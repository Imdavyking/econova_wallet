class MultiversXSignTransModel {
  String from;
  List<Transaction>? transactions;

  MultiversXSignTransModel({
    required this.from,
    this.transactions,
  });

  factory MultiversXSignTransModel.fromJson(Map<String, dynamic> json) =>
      MultiversXSignTransModel(
        from: json["from"],
        transactions: json["transactions"] == null
            ? []
            : List<Transaction>.from(
                json["transactions"].map(
                  (x) => Transaction.fromJson(x),
                ),
              ),
      );

  Map<String, dynamic> toJson() => {
        "from": from,
        "transactions": transactions == null
            ? []
            : List<dynamic>.from(transactions!.map((x) => x.toJson())),
      };
}

class Transaction {
  int? nonce;
  String? value;
  String receiver;
  String? signature;
  String sender;
  int? gasPrice;
  int? gasLimit;
  String chainId;
  String? data;
  int? version;

  Transaction({
    required this.nonce,
    required this.value,
    required this.receiver,
    required this.signature,
    required this.sender,
    required this.gasPrice,
    required this.gasLimit,
    required this.chainId,
    required this.data,
    required this.version,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        nonce: json["nonce"],
        value: json["value"],
        receiver: json["receiver"],
        sender: json["sender"],
        gasPrice: json["gasPrice"],
        gasLimit: json["gasLimit"],
        chainId: json["chainID"],
        version: json["version"],
        signature: json["signature"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "nonce": nonce,
        "value": value,
        "receiver": receiver,
        "sender": sender,
        "gasPrice": gasPrice,
        "gasLimit": gasLimit,
        "chainID": chainId,
        "version": version,
        "signature": signature,
        "data": data,
      };
}
