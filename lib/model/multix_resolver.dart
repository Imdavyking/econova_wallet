class MultiversxResolver {
  final String address;
  final int nonce;
  final String balance;
  final String rootHash;
  final int txCount;
  final int scrCount;
  final String username;
  final int shard;
  final String developerReward;

  MultiversxResolver({
    required this.address,
    required this.nonce,
    required this.balance,
    required this.rootHash,
    required this.txCount,
    required this.scrCount,
    required this.username,
    required this.shard,
    required this.developerReward,
  });

  factory MultiversxResolver.fromJson(Map<String, dynamic> json) =>
      MultiversxResolver(
        address: json["address"],
        nonce: json["nonce"],
        balance: json["balance"],
        rootHash: json["rootHash"],
        txCount: json["txCount"],
        scrCount: json["scrCount"],
        username: json["username"],
        shard: json["shard"],
        developerReward: json["developerReward"],
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "nonce": nonce,
        "balance": balance,
        "rootHash": rootHash,
        "txCount": txCount,
        "scrCount": scrCount,
        "username": username,
        "shard": shard,
        "developerReward": developerReward,
      };
}
