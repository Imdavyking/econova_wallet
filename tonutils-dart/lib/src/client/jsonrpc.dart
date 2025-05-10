// ignore_for_file: constant_identifier_names, unused_local_variable

import 'dart:convert';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/digests/sha256.dart';
import 'package:tonutils/src/_utils/records_class.dart';
import 'package:tonutils/tonutils.dart';

import '../dataformat/address/api.dart' show InternalAddress;
import '../dataformat/cell/api.dart' show beginCell, Cell;
import '../dataformat/contract/api.dart'
    show
        Contract,
        ContractGetMethodResult,
        ContractInit,
        ContractMaybeInit,
        ContractProvider,
        ContractState,
        ContractStateLast,
        ContractStateType,
        CstActive,
        CstFrozen,
        CstUninit,
        SenderArguments,
        openContract;
import '../dataformat/nano/api.dart' show Nano;
import '../dataformat/tuple/api.dart'
    show
        TiBuilder,
        TiCell,
        TiInt,
        TiNan,
        TiNull,
        TiSlice,
        TiTuple,
        TupleItem,
        TupleReader;
import '../dataformat/type/api.dart'
    show
        Message,
        SbiBigInt,
        SbiString,
        ScCell,
        ScString,
        SendMode,
        SiaInternalAddress,
        StringBigInt,
        StringCell,
        Transaction,
        comment,
        external,
        loadTransaction,
        storeMessage;

/// TON Blockchain client over jsonRPC
class TonJsonRpc {
  /// API endpoint
  final String endpoint;

  /// API key
  final String? apiKey;

  /// HTTP request timeout in milliseconds
  final int timeout;

  /// Expects an [endpoint] as either of:
  /// - 'https://testnet.toncenter.com/api/v2/jsonRPC'
  /// - 'https://toncenter.com/api/v2/jsonRPC'
  /// - your own instance of TON HTTP API,
  ///   see more here: https://github.com/toncenter/ton-http-api
  TonJsonRpc([
    this.endpoint = 'https://testnet.toncenter.com/api/v2/jsonRPC',
    this.apiKey,
    this.timeout = 30000,
  ]);

  /// Returns the address balance as a Future<BigInt>
  Future<BigInt> getBalance(InternalAddress address) async {
    return (await getContractState(address)).balance;
  }

  /// Returns the gas used and the stack after the get method invocation as a record, wrapped in a Future:
  /// ```dart
  /// Future<({
  ///   int gasUsed,
  ///   TupleReader stack,
  /// })>
  /// ```
  ///
  /// Throws 'Unable to execute...' if the exit code != 0
  Future<RecordGas> runMethod(
    InternalAddress address,
    String methodName, [
    List<TupleItem> stack = const <TupleItem>[],
  ]) async {
    var res = await _callGetMethod(address, methodName, stack);
    if (res.exitCode != 0) {
      throw 'Unable to execute get method, got exit code ${res.exitCode}';
    }
    return RecordGas(
      gasUsed: res.gasUsed,
      stack: _deserializeStack(res.stack),
    );
  }

  /// Returns the gas used, stack and the exit code after the get method invocation as a record, wrapped in a Future:
  /// ```dart
  /// Future<({
  ///   int gasUsed,
  ///   TupleReader stack,
  ///   int exitCode
  /// })>
  /// ```
  Future<RecordGasExitCode> runMethodWithError(
    InternalAddress address,
    String methodName,
    List<TupleItem> stack,
  ) async {
    var res = await _callGetMethod(address, methodName, stack);

    return RecordGasExitCode(
      gasUsed: res.gasUsed,
      stack: _deserializeStack(res.stack),
      exitCode: res.exitCode,
    );
  }

  /// Returns a List<Transaction> wrapped in a Future
  Future<List<Transaction>> getTransactions(
    InternalAddress address, {
    required int limit,
    String? lt,
    String? hash,
    String? toLt,
    bool? inclusive,
  }) async {
    var tx = await _getTransactions(
      address,
      limit: limit,
      lt: lt,
      hash: hash,
      toLt: toLt,
      inclusive: inclusive,
    );

    var res = <Transaction>[];
    for (var i = 0; i < tx.transactions.length; i += 1) {
      var boc = base64.decode(tx.transactions[i].data);
      res.add(
        loadTransaction(
          Cell.fromBoc(boc)[0].beginParse(),
          tx.transactions[i].transactionId.hash,
        ),
      );
    }

    return res;
  }

  /// Returns a transaction by its logical time [lt] and a base64 encoded [hash] as a Transaction? wrapped in a Future
  Future<Transaction?> getTransaction(
    InternalAddress address,
    String lt,
    String hash,
  ) async {
    var res = await _getTransaction(address, lt, hash);
    if (res != null) {
      var boc = base64.decode(res.data);
      return loadTransaction(Cell.fromBoc(boc)[0].beginParse());
    }
    return null;
  }

  /// Returns the latest masterchain info as a record, wrapped in a Future:
  /// ```dart
  /// Future<({
  ///   int initSeqno,
  ///   int latestSeqno,
  ///   String shard,
  ///   int workchain,
  /// })>
  /// ```
  Future<MasterChainInfo> getMasterchainInfo() async {
    var res = await _getMasterchainInfo();

    return MasterChainInfo(
      workchain: res.init.workchain,
      shard: res.last.shard,
      initSeqno: res.init.seqno,
      latestSeqno: res.last.seqno,
    );
  }

  /// Returns the latest workchain shards as a List of records, wrapped in a Future:
  /// ```dart
  /// Future<List<({
  ///   int workchain,
  ///   String shard,
  ///   int seqno,
  /// })>>
  /// ```
  Future<List<WorkchainShards>> getWorkchainShards(int seqno) async {
    var shards = (await _getShards(seqno)).shards;
    var res = <WorkchainShards>[];

    for (var i = 0; i < shards.length; i += 1) {
      res.add(WorkchainShards(
        workchain: shards[i].workchain,
        shard: shards[i].shard,
        seqno: shards[i].seqno,
      ));
    }

    return res;
  }

  /// Returns the latest workchain shards as a List of records, wrapped in a Future:
  /// ```dart
  /// Future<List<({
  ///   InternalAddress account,
  ///   LastTransactionId lastTransactionId,
  /// })>>
  /// ```
  ///
  /// Throws 'Unsupported' if the incomplete flag is true
  Future<List<ShardTransactions>> getShardTransactions(
      int workchain, int seqno, String shard) async {
    var tx = await _getBlockTransactions(workchain, seqno, shard);
    if (tx.incomplete == true) {
      throw 'Unsupported';
    }
    var res = <ShardTransactions>[];

    for (var i = 0; i < tx.transactions.length; i += 1) {
      res.add(ShardTransactions(
        account: InternalAddress.parseRaw(tx.transactions[i].account),
        lastTransactionId: LastTransactionId(
          lt: tx.transactions[i].lt,
          hash: tx.transactions[i].hash,
        ),
      ));
    }

    return res;
  }

  /// Returns nothing, sends a message [src] as a BoC to the network
  Future<void> sendMessage(Message src) async {
    final boc = beginCell().store(storeMessage(src)).endCell().toBoc();
    await _sendBoc(boc);
  }

  /// Returns nothing, sends a BoC file [src] directly to the network
  Future<void> sendFile(Uint8List src) async {
    await _sendBoc(src);
  }

  /// Returns a fee estimate for the external message as a record, wrapped in a Future:
  /// ```dart
  /// Future<({
  ///   int inForwardFee,
  ///   int storageFee,
  ///   int gasFee,
  ///   int forwardFee,
  /// })>
  /// ```
  Future<EstimateExternalMessageFee> estimateExternalMessageFee(
    InternalAddress address, {
    required Cell body,
    Cell? initCode,
    Cell? initData,
    required bool ignoreSignature,
  }) async {
    var fees = await _estimateFee(
      address,
      body: body,
      initCode: initCode,
      initData: initData,
      ignoreSignature: ignoreSignature,
    );

    return EstimateExternalMessageFee(
      inForwardFee: fees.sourceFees.inForwardFee,
      storageFee: fees.sourceFees.storageFee,
      gasFee: fees.sourceFees.gasFee,
      forwardFee: fees.sourceFees.forwardFee,
    );
  }

  /// Returns nothing, sends an external message to contract
  sendExternalMessage(Contract contract, Cell src) async {
    var isDeployed = await isContractDeployed(contract.address);

    if (isDeployed) {
      final message = external(
        to: SiaInternalAddress(contract.address),
        body: src,
      );
      await sendMessage(message);
      return;
    }

    final message = external(
      to: SiaInternalAddress(contract.address),
      init: ContractMaybeInit(
        code: contract.init?.code,
        data: contract.init?.data,
      ),
      body: src,
    );
    await sendMessage(message);
  }

  /// Returns a bool, wrapped in a Future: true if contract is in active state, false otherwise
  Future<bool> isContractDeployed(InternalAddress address) async {
    return (await getContractState(address)).state == 'active';
  }

  /// Returns a contract state as a record, wrapped in a Future:
  /// ```dart
  /// Future<({
  ///   BigInt balance,
  ///   String state,
  ///   Uint8List? code,
  ///   Uint8List? data,
  ///   LastTransactionId? lastTransaction,
  ///   ({int seqno, String shard, int workchain}) blockId,
  ///   int timestamp
  /// })>
  /// ```
  Future<RecordContractState> getContractState(InternalAddress address) async {
    var info = await _getAddressInformation(address);

    BigInt balance = BigInt.from(0);

    if (info.balance is SbiString) {
      balance = BigInt.parse((info.balance as SbiString).value);
    } else if (info.balance is SbiBigInt) {
      balance = (info.balance as SbiBigInt).value;
    }

    var state = info.state;

    return RecordContractState(
      balance: balance,
      state: state,
      code:
          info.code != '' ? Uint8List.fromList(base64.decode(info.code)) : null,
      data:
          info.data != '' ? Uint8List.fromList(base64.decode(info.data)) : null,
      lastTransaction: info.lastTransactionId.lt != '0'
          ? LastTransactionId(
              lt: info.lastTransactionId.lt,
              hash: info.lastTransactionId.hash,
            )
          : null,
      blockId: WorkchainShards(
          workchain: info.blockId.workchain,
          shard: info.blockId.shard,
          seqno: info.blockId.seqno),
      timestamp: info.syncUtime,
    );
  }

  /// Returns a new opened contract with the ContractProvider initialized
  T open<T extends Contract>(T src) {
    return openContract<T>(
        src,
        ({required InternalAddress address, ContractInit? init}) =>
            _createProvider(
                this,
                address,
                init != null
                    ? ContractMaybeInit(
                        code: init.code,
                        data: init.data,
                      )
                    : null));
  }

  /// Returns a new ContractProvider
  ContractProvider provider(InternalAddress address, ContractMaybeInit init) {
    return _createProvider(this, address, init);
  }

  ContractProvider _createProvider(
    TonJsonRpc client,
    InternalAddress address,
    ContractMaybeInit? init,
  ) {
    return ContractProvider(
      // getState
      () async {
        var state = await client.getContractState(address);
        var balance = state.balance;
        var last = state.lastTransaction != null
            ? ContractStateLast(
                lt: BigInt.parse(state.lastTransaction!.lt),
                hash: Uint8List.fromList(
                    base64.decode(state.lastTransaction!.hash)),
              )
            : null;
        ContractStateType storage;
        switch (state.state) {
          case 'active':
            // Add a 'break' statement at the end of the 'case' block.

            storage = CstActive(
              code: state.code,
              data: state.data,
            );
            break;
          case 'uninitialized':
            storage = CstUninit();
            break;

          case 'frozen':
            storage = CstFrozen(stateHash: Uint8List(0));
            break;

          default:
            throw 'Unsupported state ${state.state}';
        }

        return ContractState(
          balance: balance,
          last: last,
          state: storage,
        );
      },
      // get
      (name, args) async {
        var method = await client.runMethod(address, name, args);
        return ContractGetMethodResult(
          stack: method.stack,
          gasUsed: BigInt.from(method.gasUsed),
        );
      },
      // external
      (message) async {
        // Resolve init
        ContractMaybeInit? neededInit;
        if (init != null &&
            (await client.isContractDeployed(address)) == false) {
          neededInit = init;
        }

        // Send
        final ext = external(
          to: SiaInternalAddress(address),
          init: neededInit,
          body: message,
        );
        var boc = beginCell().store(storeMessage(ext)).endCell().toBoc();
        await client.sendFile(boc);
      },
      // internal
      (
        via, {
        required StringBigInt value,
        StringCell? body,
        bool? bounce,
        SendMode? sendMode,
      }) async {
        // Resolve init
        ContractMaybeInit neededInit = ContractMaybeInit();
        if (init != null &&
            (await client.isContractDeployed(address)) == false) {
          neededInit = init;
        }

        // Resolve bounce
        var lBounce = true;
        if (bounce != null) {
          lBounce = bounce;
        }

        // Resolve value
        BigInt lValue = BigInt.from(0);

        if (value is SbiString) {
          lValue = Nano.fromString(value.value);
        } else if (value is SbiBigInt) {
          lValue = value.value;
        }

        // Resolve body
        Cell lBody = Cell();

        if (body is ScString) {
          lBody = comment(body.value);
        } else if (body is ScCell) {
          lBody = body.value;
        } else if (body == null) {
          // Handle the case where body is null
        } else {
          // Handle the case where body is neither ScString nor ScCell nor null
        }

        // Send internal message
        await via.send(SenderArguments(
          to: address,
          value: lValue,
          bounce: lBounce,
          sendMode: sendMode,
          init: neededInit,
          body: lBody,
        ));
      },
    );
  }

  // NOTE: consider making those functions into separate utils?
  static List<List<String>> _serializeStack(List<TupleItem> src) {
    var stack = <List<String>>[];
    for (var i = 0; i < src.length; i += 1) {
      var item = src[i];

      if (item is TiInt) {
        stack.add(['num', item.value.toString()]);
      } else if (item is TiCell) {
        stack.add(['tvm.Cell', base64.encode(item.cell.toBoc())]);
      } else if (item is TiSlice) {
        stack.add(['tvm.Slice', base64.encode(item.cell.toBoc())]);
      } else if (item is TiBuilder) {
        stack.add(['tvm.Builder', base64.encode(item.cell.toBoc())]);
      } else if (item is TiTuple || item is TiNan || item is TiNull) {
        throw 'Unsupported stack item type: ${item.runtimeType}';
      }
    }
    return stack;
  }

  static TupleReader _deserializeStack(List<List<String>> src) {
    var stack = <TupleItem>[];
    for (var i = 0; i < src.length; i += 1) {
      switch (src[i][0]) {
        case 'num':
          var v = src[i][1];
          if (v.startsWith('-')) {
            stack.add(TiInt(
              -BigInt.parse(v.substring(1)),
            ));
          } else {
            stack.add(TiInt(
              BigInt.parse(v),
            ));
          }
          break;

        case 'null':
          stack.add(TiNull());
          break;
        case 'cell':
          stack.add(TiCell(Cell.fromBocBase64(src[i][1])));
          break;

        case 'slice':
          stack.add(TiSlice(Cell.fromBocBase64(src[i][1])));
          break;

        case 'builder':
          stack.add(TiBuilder(Cell.fromBocBase64(src[i][1])));
          break;

        default:
          throw 'Unsupported stack item type ${src[i][0]}';
      }
    }
    return TupleReader(stack);
  }

  dynamic _call(String method, Map<String, dynamic> body) async {
    var headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (apiKey != null) {
      headers['X-API-Key'] = apiKey!;
    }

    var uri = Uri.parse(endpoint);

    var response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(<String, dynamic>{
        'id': '1',
        'jsonrpc': '2.0',
        'method': method,
        'params': body,
      }),
    );
    switch (response.statusCode) {
      case 504:
        throw 'Lite Server Timeout, ${response.reasonPhrase}';
      case 422:
        throw 'Validation Error on Lite Server, ${response.reasonPhrase}';
      default:
        break;
    }

    var decoded = jsonDecode(response.body);

    if (decoded['ok'] == false) {
      // ignore: prefer_interpolation_to_compose_strings
      throw 'Received an error: ' + decoded['error'];
    }

    return decoded['result'];
  }

  Future<RpcCallGetMethod> _callGetMethod(
    InternalAddress address,
    String method,
    List<TupleItem> stack,
  ) async {
    var res = await _call('runGetMethod', <String, dynamic>{
      'address': address.toString(),
      'method': method,
      'stack': _serializeStack(stack),
    });
    return _parseCallGetMethod(res);
  }

  Future<RpcGetTransaction?> _getTransaction(
    InternalAddress address,
    String lt,
    String hash,
  ) async {
    var convHash = hex.encode(base64.decode(hash));
    var res = await _call('getTransactions', <String, dynamic>{
      'address': address.toString(),
      'lt': lt,
      'hash': convHash,
      'limit': 1,
    });
    var parsed = _parseGetTransactions(res);

    String convToFriendly(String src) =>
        src.replaceAll(RegExp(r'\-'), '+').replaceAll(RegExp(r'_'), '/');

    var ex = parsed.transactions.firstWhereOrNull((v) {
      return v.transactionId.lt == lt &&
          v.transactionId.hash == convToFriendly(hash);
    });

    return ex;
  }

  Future<RpcGetTransactions> _getTransactions(
    InternalAddress address, {
    required int limit,
    String? lt,
    String? hash,
    String? toLt,
    bool? inclusive,
  }) async {
    // Convert hash
    String lHash = '';
    if (hash != null) {
      lHash = hex.encode(base64.decode(hash));
    }

    // Adjust limit
    var lLimit = limit;
    if (hash != null && lt != null && inclusive != true) {
      lLimit += 1;
    }

    // Do request
    var body = <String, dynamic>{
      'address': address.toString(),
      'limit': lLimit,
      'hash': lHash,
    };
    if (lt != null) {
      body['lt'] = lt;
    }
    if (toLt != null) {
      body['to_lt'] = toLt;
    }
    var res = await _call('getTransactions', body);
    var parsed = _parseGetTransactions(res);
    if (parsed.transactions.length > lLimit) {
      parsed.transactions = parsed.transactions.sublist(0, limit);
    }

    // Adjust result
    if (hash != null && lt != null && inclusive != null && inclusive != true) {
      parsed.transactions.removeAt(0);
    }

    return parsed;
  }

  BigInt readIntFromBitString(List bs, int cursor, int bits) {
    BigInt n = BigInt.from(0);

    for (int i = 0; i < bits; i++) {
      n *= BigInt.from(2);

      n += BigInt.from(_get(bs, cursor + i));
    }
    return n;
  }

  int _get(List data, int index) {
    final get = (data[index ~/ 8 | 0] & (1 << (7 - (index % 8)))) > 0;
    return get ? 1 : 0;
  }

  InternalAddress parseAddress(List bits) {
    BigInt n = readIntFromBitString(bits, 3, 8);

    if (n > BigInt.from(127)) {
      n = n - BigInt.from(256);
    }

    final hashPart = readIntFromBitString(bits, 3 + 8, 256);

    if ("$n:$hashPart" == "0:0") {
      throw Exception('not found');
    }
    final s =
        "${n.toRadixString(10)}:${hashPart.toRadixString(16).padRight(64, "0")}";

    return InternalAddress.parseRaw(s);
  }

  InternalAddress parseSmartContractAddressImpl(Cell cell, prefix0, prefix1) {
    List<int> bits = cell.bits.toPaddedList();

    if (bits[0] != prefix0 || bits[1] != prefix1) {
      throw Exception("Invalid dns record value prefix");
    }

    bits[bits.length - 1] = bits[bits.length - 1] - 16;

    bits = bits.slice(2);

    return parseAddress(bits);
  }

  InternalAddress parseSmartContractAddressRecord(Cell cell) {
    return parseSmartContractAddressImpl(cell, 0x9f, 0xd3);
  }

  InternalAddress parseNextResolverRecord(Cell cell) {
    return parseSmartContractAddressImpl(cell, 0xba, 0x93);
  }

  Future<InternalAddress?> dnsResolveImpl(
    Uint8List rawDomainBytes,
    String dnsAddress,
    String category,
  ) async {
    final len = rawDomainBytes.length * 8;
    var builder = BitBuilder();
    builder.writeList(rawDomainBytes);

    final domainCell = Cell(bits: BitString(builder.list(), 0, builder.length));
    final categoryBN = await categoryToBN('wallet');

    final result = await call2(dnsAddress, "dnsresolve", [
      ["tvm.Slice", base64.encode(domainCell.toBoc())],
      ["num", categoryBN.toString()],
    ]);
    BigInt first = result[0];
    int resultLen = first.toInt();

    Cell cell = result[1];

    if (resultLen == 0) {
      return null;
    }

    if (resultLen % 8 != 0) {
      throw Exception("domain split not at a component boundary");
    }

    const DNS_CATEGORY_NEXT_RESOLVER = "dns_next_resolver";
    const DNS_CATEGORY_WALLET = "wallet";
    const DNS_CATEGORY_SITE = "site";
    const DNS_CATEGORY_STORAGE = "storage";
    if (resultLen > len) {
      throw Exception("invalid response $resultLen/$len");
    } else if (resultLen == len) {
      if (category == DNS_CATEGORY_NEXT_RESOLVER) {
        return cell != Cell.empty ? parseNextResolverRecord(cell) : null;
      } else if (category == DNS_CATEGORY_WALLET) {
        return cell != Cell.empty
            ? parseSmartContractAddressRecord(cell)
            : null;
      } else {
        throw Exception('not supported');
      }
      //  else if (category == DNS_CATEGORY_SITE) {
      //   return cell != Cell.empty ? parseSiteRecord(cell) : null;
      // } else if (category == DNS_CATEGORY_STORAGE) {
      //   return cell != Cell.empty ? parseStorageBagIdRecord(cell) : null;
      // } else {
      //   return cell;
      // }
    } else {
      if (cell == Cell.empty) {
        return null; // domain cannot be resolved
      } else {
        const oneStep = false;
        final nextAddress = parseNextResolverRecord(cell);
        if (oneStep) {
          if (category == DNS_CATEGORY_NEXT_RESOLVER) {
            return nextAddress;
          } else {
            return null;
          }
        } else {
          final newBytes = rawDomainBytes.slice(resultLen ~/ 8).toList();

          return await dnsResolveImpl(
            Uint8List.fromList(newBytes),
            nextAddress.toRawString(),
            category,
          );
        }
      }
    }
  }

  parseObject(x) {
    final typeName = x["@type"];
    switch (typeName) {
      case "tvm.list":
      case "tvm.tuple":
        List element = x['elements'];
        return element.map(parseObject);
      case "tvm.cell":
        return Cell.fromBocBase64(x['bytes']);
      case "tvm.stackEntryCell":
        return parseObject(x['cell']);
      case "tvm.stackEntryTuple":
        return parseObject(x['tuple']);
      case "tvm.stackEntryNumber":
        return parseObject(x['number']);
      case "tvm.numberDecimal":
        return BigInt.parse(x['number'], radix: 10);
      default:
        throw Exception("unknown type $typeName");
    }
  }

  parseResponseStack(pair) {
    final typeName = pair[0];
    final value = pair[1];

    switch (typeName) {
      case "num":
        return BigInt.parse(value);
      case "list":
      case "tuple":
        return parseObject(value);
      case "cell":
        return Cell.fromBocBase64(value['bytes']);
      default:
        throw Exception("unknown type $typeName");
    }
  }

  Future categoryToBN(String category) async {
    if (category.isEmpty) return BigInt.from(0);
    final categoryBytes = utf8.encode(category);
    Uint8List categoryHash =
        SHA256Digest().process(Uint8List.fromList(categoryBytes));
    final result = BigInt.parse(hex.encode(categoryHash), radix: 16);
    return result;
  }

  Future<InternalAddress?> resolveDomain(String domainName) async {
    final rootDnsAddress = await getRootDnsAddress();
    Uint8List bytes = domainToBytes(domainName);

    final resolve =
        await dnsResolveImpl(bytes, rootDnsAddress.toRawString(), 'wallet');
    return resolve;
  }

  Future<List<dynamic>> call2(address, method, List params) async {
    var rawResult = await _call(
      'runGetMethod',
      <String, dynamic>{"address": address, "method": method, "stack": params},
    );

    if (rawResult['exit_code'] != 0) {
      throw Exception("http provider parse response error");
    }

    List<dynamic> stack = rawResult['stack'];

    final arr = stack.map(parseResponseStack).toList();

    return arr.length == 1 ? arr[0] : arr;
  }

  Uint8List domainToBytes(String domain) {
    if (domain.isEmpty) {
      throw ArgumentError("empty domain");
    }
    if (domain == ".") {
      return Uint8List.fromList([0]);
    }

    domain = domain.toLowerCase();

    for (int i = 0; i < domain.length; i++) {
      if (domain.codeUnitAt(i) <= 32) {
        throw ArgumentError(
            "bytes in range 0..32 are not allowed in domain names");
      }
    }

    for (int i = 0; i < domain.length; i++) {
      String s = domain.substring(i, i + 1);
      for (int c = 127; c <= 159; c++) {
        // another control codes range
        if (s == String.fromCharCode(c)) {
          throw ArgumentError(
              "bytes in range 127..159 are not allowed in domain names");
        }
      }
    }

    List<String> arr = domain.split(".");

    for (var part in arr) {
      if (part.isEmpty) {
        throw ArgumentError("domain name cannot have an empty component");
      }
    }

    String rawDomain = "${arr.reversed.join("\x00")}${"\x00"}";

    if (rawDomain.length < 126) {
      rawDomain = "${"\x00"}$rawDomain";
    }

    return Uint8List.fromList(utf8.encode(rawDomain));
  }

  Future<InternalAddress> getRootDnsAddress() async {
    final cell = await _getConfigParam(4);

    final byteArray = cell.bits.toPaddedList();
    if (byteArray.length != 256 / 8) {
      throw Exception("Invalid ConfigParam 4 length ${byteArray.length}");
    }
    final hexMatch = hex.encode(byteArray);

    return InternalAddress.parseRaw("-1:$hexMatch");
  }

  Future<Cell> _getConfigParam(
    int configParamId,
  ) async {
    var rawResult = await _call(
      'getConfigParam',
      <String, dynamic>{"config_id": configParamId},
    );

    if (rawResult['@type'] != 'configInfo') {
      throw Exception('getConfigParam expected type configInfo');
    }
    if (rawResult['config'] == null) {
      throw Exception('getConfigParam expected config');
    }
    if (rawResult['config']['@type'] != 'tvm.cell') {
      throw Exception('getConfigParam expected type tvm.cell');
    }
    if (rawResult['config']['bytes'] == null) {
      throw Exception('getConfigParam expected bytes');
    }

    return Cell.fromBocBase64(rawResult['config']['bytes']);
  }

  Future<RpcAddressInformation> _getAddressInformation(
    InternalAddress address,
  ) async {
    var res = await _call('getAddressInformation', <String, dynamic>{
      'address': address.toString(),
    });
    var parsed = _parseAddressInformation(res);

    return parsed;
  }

  Future<RpcMasterchainInfo> _getMasterchainInfo() async {
    var res = await _call('getMasterchainInfo', <String, dynamic>{});
    var parsed = _parseMasterchainInfo(res);

    return parsed;
  }

  Future<void> _sendBoc(Uint8List body) async {
    await _call('sendBoc', <String, dynamic>{
      'boc': base64.encode(body),
    });
  }

  Future<RpcEstimateFee> _estimateFee(
    InternalAddress address, {
    required Cell body,
    Cell? initCode,
    Cell? initData,
    required bool ignoreSignature,
  }) async {
    var res = await _call('estimateFee', <String, dynamic>{
      'address': address.toString(),
      'body': base64.encode(body.toBoc()),
      'init_data': initData != null ? base64.encode(initData.toBoc()) : '',
      'init_code': initCode != null ? base64.encode(initCode.toBoc()) : '',
      'ignore_chksig': ignoreSignature,
    });
    var parsed = _parseEstimateFee(res);

    return parsed;
  }

  Future<RpcGetShards> _getShards(int seqno) async {
    var res = await _call('shards', <String, dynamic>{
      'seqno': seqno,
    });
    var parsed = _parseGetShards(res);

    return parsed;
  }

  Future<RpcBlockTransactions> _getBlockTransactions(
    int workchain,
    int seqno,
    String shard,
  ) async {
    var res = await _call('getBlockTransactions', <String, dynamic>{
      'workchain': workchain,
      'seqno': seqno,
      'shard': shard,
    });
    var parsed = _parseGetBlockTransactions(res);

    return parsed;
  }
}

//
// Types
//

class RpcResponse {}

//

class RpcBlockShortTxt {
  int mode;
  String account;
  String lt;
  String hash;

  RpcBlockShortTxt({
    required this.mode,
    required this.account,
    required this.lt,
    required this.hash,
  });
}

class RpcBlockTransactions extends RpcResponse {
  RpcBlockIdExt id;
  int reqCount;
  bool incomplete;
  List<RpcBlockShortTxt> transactions;

  RpcBlockTransactions({
    required this.id,
    required this.reqCount,
    required this.incomplete,
    required this.transactions,
  });
}

RpcBlockTransactions _parseGetBlockTransactions(dynamic responseData) {
  var id = RpcBlockIdExt(
    workchain: responseData['id']['workchain'] as int,
    shard: responseData['id']['shard'] as String,
    seqno: responseData['id']['seqno'] as int,
    rootHash: responseData['id']['root_hash'] as String,
    fileHash: responseData['id']['file_hash'] as String,
  );
  var reqCount = responseData['req_count'] as int;
  var incomplete = responseData['incomplete'] as bool;

  var rawTransactions = responseData['transactions'] as List<dynamic>;
  var transactions = <RpcBlockShortTxt>[];
  for (var i = 0; i < rawTransactions.length; i += 1) {
    transactions.add(RpcBlockShortTxt(
      mode: rawTransactions[i]['mode'] as int,
      account: rawTransactions[i]['account'] as String,
      lt: rawTransactions[i]['lt'] as String,
      hash: rawTransactions[i]['hash'] as String,
    ));
  }

  return RpcBlockTransactions(
    id: id,
    reqCount: reqCount,
    incomplete: incomplete,
    transactions: transactions,
  );
}

//

class RpcGetShards extends RpcResponse {
  List<RpcBlockIdExt> shards;

  RpcGetShards({
    required this.shards,
  });
}

RpcGetShards _parseGetShards(dynamic responseData) {
  var rawShards = responseData['shards'] as List<dynamic>;
  var shards = <RpcBlockIdExt>[];
  for (var i = 0; i < rawShards.length; i += 1) {
    shards.add(RpcBlockIdExt(
      workchain: rawShards[i]['workchain'] as int,
      shard: rawShards[i]['shard'] as String,
      seqno: rawShards[i]['seqno'] as int,
      rootHash: rawShards[i]['root_hash'] as String,
      fileHash: rawShards[i]['file_hash'] as String,
    ));
  }

  return RpcGetShards(shards: shards);
}

//

class RpcSourceFee {
  int inForwardFee;
  int storageFee;
  int gasFee;
  int forwardFee;

  RpcSourceFee({
    required this.inForwardFee,
    required this.storageFee,
    required this.gasFee,
    required this.forwardFee,
  });
}

class RpcEstimateFee extends RpcResponse {
  RpcSourceFee sourceFees;

  RpcEstimateFee({
    required this.sourceFees,
  });
}

RpcEstimateFee _parseEstimateFee(dynamic responseData) {
  var sourceFee = RpcSourceFee(
    inForwardFee: responseData['source_fees']['in_fwd_fee'] as int,
    storageFee: responseData['source_fees']['storage_fee'] as int,
    gasFee: responseData['source_fees']['gas_fee'] as int,
    forwardFee: responseData['source_fees']['fwd_fee'] as int,
  );
  return RpcEstimateFee(sourceFees: sourceFee);
}

class RpcMasterchainInfo extends RpcResponse {
  String stateRootHash;
  RpcBlockIdExt last;
  RpcBlockIdExt init;

  RpcMasterchainInfo({
    required this.stateRootHash,
    required this.last,
    required this.init,
  });
}

RpcMasterchainInfo _parseMasterchainInfo(dynamic responseData) {
  var stateRootHash = responseData['state_root_hash'] as String;
  var last = RpcBlockIdExt(
    workchain: responseData['last']['workchain'] as int,
    shard: responseData['last']['shard'] as String,
    seqno: responseData['last']['seqno'] as int,
    rootHash: responseData['last']['root_hash'] as String,
    fileHash: responseData['last']['file_hash'] as String,
  );
  var init = RpcBlockIdExt(
    workchain: responseData['init']['workchain'] as int,
    shard: responseData['init']['shard'] as String,
    seqno: responseData['init']['seqno'] as int,
    rootHash: responseData['init']['root_hash'] as String,
    fileHash: responseData['init']['file_hash'] as String,
  );

  return RpcMasterchainInfo(
    stateRootHash: stateRootHash,
    last: last,
    init: init,
  );
}

//

class RpcBlockIdExt extends RpcResponse {
  int workchain;
  String shard;
  int seqno;
  String rootHash;
  String fileHash;

  RpcBlockIdExt({
    required this.workchain,
    required this.shard,
    required this.seqno,
    required this.rootHash,
    required this.fileHash,
  });
}

/// ```dart
/// ({
///   String lt,
///   String hash,
/// })
/// ```
class LastTransactionId {
  String lt;
  String hash;

  LastTransactionId({
    required this.lt,
    required this.hash,
  });
}

class RpcAddressInformation extends RpcResponse {
  StringBigInt balance;
  String state;
  String data;
  String code;
  LastTransactionId lastTransactionId;
  RpcBlockIdExt blockId;
  int syncUtime;

  RpcAddressInformation({
    required this.balance,
    required this.state,
    required this.data,
    required this.code,
    required this.lastTransactionId,
    required this.blockId,
    required this.syncUtime,
  });
}

RpcAddressInformation _parseAddressInformation(dynamic responseData) {
  StringBigInt balance;
  switch (responseData['balance'].runtimeType) {
    case String:
      balance = SbiString(responseData['balance'] as String);
      break;

    case int:
      balance = SbiBigInt(BigInt.from(responseData['balance'] as int));
      break;

    case BigInt:
      balance = SbiBigInt(responseData['balance'] as BigInt);
      break;

    default:
      throw 'Unexpected type of the balance: ${responseData['balance'].runtimeType}';
  }
  var state = responseData['state'] as String;
  var data = responseData['data'] as String;
  var code = responseData['code'] as String;
  var lastTransactionId = LastTransactionId(
    lt: responseData['last_transaction_id']['lt'] as String,
    hash: responseData['last_transaction_id']['hash'] as String,
  );
  var blockId = RpcBlockIdExt(
    workchain: responseData['block_id']['workchain'] as int,
    shard: responseData['block_id']['shard'] as String,
    seqno: responseData['block_id']['seqno'] as int,
    rootHash: responseData['block_id']['root_hash'] as String,
    fileHash: responseData['block_id']['file_hash'] as String,
  );
  var syncUtime = responseData['sync_utime'] as int;

  return RpcAddressInformation(
    balance: balance,
    state: state,
    data: data,
    code: code,
    lastTransactionId: lastTransactionId,
    blockId: blockId,
    syncUtime: syncUtime,
  );
}

//

class RpcGetTransactions extends RpcResponse {
  List<RpcGetTransaction> transactions;

  RpcGetTransactions({
    required this.transactions,
  });
}

RpcGetTransactions _parseGetTransactions(dynamic responseData) {
  var list = responseData as List<dynamic>;
  var transactions = <RpcGetTransaction>[];

  for (var i = 0; i < list.length; i += 1) {
    transactions.add(_parseGetTransaction(list[i]));
  }

  return RpcGetTransactions(transactions: transactions);
}

//

class RpcMessageData {}

class RmdRaw extends RpcMessageData {
  String body;

  RmdRaw({
    required this.body,
  });
}

class RmdText extends RpcMessageData {
  String text;

  RmdText({
    required this.text,
  });
}

class RmdDecryptedText extends RpcMessageData {
  String text;

  RmdDecryptedText({
    required this.text,
  });
}

class RmdEncryptedText extends RpcMessageData {
  String text;

  RmdEncryptedText({
    required this.text,
  });
}

class RpcMessage {
  String source;
  String destination;
  String value;
  String forwardFee;
  String ihrFee;
  String createdLt;
  String bodyHash;
  RpcMessageData msgData;

  RpcMessage({
    required this.source,
    required this.destination,
    required this.value,
    required this.forwardFee,
    required this.ihrFee,
    required this.createdLt,
    required this.bodyHash,
    required this.msgData,
  });
}

class RpcTransactionId {
  String lt;
  String hash;

  RpcTransactionId({
    required this.lt,
    required this.hash,
  });
}

class RpcGetTransaction extends RpcResponse {
  String data;
  int utime;
  RpcTransactionId transactionId;
  String fee;
  String storageFee;
  String otherFee;
  RpcMessage? inMsg;
  List<RpcMessage> outMsgs;

  RpcGetTransaction({
    required this.data,
    required this.utime,
    required this.transactionId,
    required this.fee,
    required this.storageFee,
    required this.otherFee,
    this.inMsg,
    required this.outMsgs,
  });
}

RpcMessage _parseRpcMessage(dynamic responseData) {
  var source = responseData['source'] as String;
  var destination = responseData['destination'] as String;
  var value = responseData['value'] as String;
  var forwardFee = responseData['fwd_fee'] as String;
  var ihrFee = responseData['ihr_fee'] as String;
  var createdLt = responseData['created_lt'] as String;
  var bodyHash = responseData['body_hash'] as String;
  RpcMessageData msgData;

  switch (responseData['msg_data']['@type']) {
    case 'msg.dataRaw':
      msgData = RmdRaw(body: responseData['msg_data']['body'] as String);
      break;

    case 'msg.dataText':
      msgData = RmdText(text: responseData['msg_data']['text'] as String);
      break;

    case 'msg.dataDecryptedText':
      msgData =
          RmdDecryptedText(text: responseData['msg_data']['text'] as String);
      break;

    case 'msg.dataEncryptedText':
      msgData =
          RmdEncryptedText(text: responseData['msg_data']['text'] as String);
      break;

    default:
      throw 'Unsupported @type of the message: ${responseData["@type"]}';
  }

  return RpcMessage(
    source: source,
    destination: destination,
    value: value,
    forwardFee: forwardFee,
    ihrFee: ihrFee,
    createdLt: createdLt,
    bodyHash: bodyHash,
    msgData: msgData,
  );
}

RpcGetTransaction _parseGetTransaction(dynamic responseData) {
  var data = responseData['data'] as String;
  var utime = responseData['utime'] as int;
  var transactionId = RpcTransactionId(
    lt: responseData['transaction_id']['lt'] as String,
    hash: responseData['transaction_id']['hash'] as String,
  );
  var fee = responseData['fee'] as String;
  var storageFee = responseData['storage_fee'] as String;
  var otherFee = responseData['other_fee'] as String;

  var inMsg = responseData['in_msg'] != null
      ? _parseRpcMessage(responseData['in_msg'])
      : null;

  var rawMsgs = responseData['out_msgs'] as List<dynamic>;
  var outMsgs = <RpcMessage>[];

  for (var i = 0; i < rawMsgs.length; i += 1) {
    outMsgs.add(_parseRpcMessage(rawMsgs[i]));
  }

  return RpcGetTransaction(
    data: data,
    utime: utime,
    transactionId: transactionId,
    fee: fee,
    storageFee: storageFee,
    otherFee: otherFee,
    inMsg: inMsg,
    outMsgs: outMsgs,
  );
}

//

class RpcCallGetMethod extends RpcResponse {
  int gasUsed;
  int exitCode;
  List<List<String>> stack;

  RpcCallGetMethod({
    required this.gasUsed,
    required this.exitCode,
    required this.stack,
  });
}

RpcCallGetMethod _parseCallGetMethod(dynamic responseData) {
  var gasUsed = responseData['gas_used'] as int;
  var exitCode = responseData['exit_code'] as int;

  var rawStack = responseData['stack'] as List<dynamic>;
  var stack = <List<String>>[];

  for (var i = 0; i < rawStack.length; i += 1) {
    var rsi = rawStack[i] as List<dynamic>;
    var stacki = <String>[];

    for (var j = 0; j < rsi.length; j += 1) {
      if (rsi[j] is Map<String, dynamic>) {
        stacki.add(rsi[j]['bytes'] as String);
        continue;
      }

      if (rsi[j] is String) {
        stacki.add(rsi[j] as String);
        continue;
      }

      throw 'Item ${rsi[j]} is not a Map<String, dynamic> nor a String; current main stack is:\n$stack\n\nCurrently formed stack is:\n$stacki';
    }

    stack.add(stacki);
  }

  return RpcCallGetMethod(
    gasUsed: gasUsed,
    exitCode: exitCode,
    stack: stack,
  );
}
