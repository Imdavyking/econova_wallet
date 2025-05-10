import '../interface/coin.dart';

class SendTrxInfo {
  final double fee;
  final double balance;
  final Coin coin;
  const SendTrxInfo({
    required this.fee,
    required this.balance,
    required this.coin,
  });

  Future<SendTrxInfo> fetchInfo(String amount, String recipient) async {
    return SendTrxInfo(
      fee: await coin.getTransactionFee(
        amount,
        recipient,
      ),
      balance: await coin.getBalance(false),
      coin: coin,
    );
  }
}
