//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:algorand_kmd/src/date_serializer.dart';
import 'package:algorand_kmd/src/model/date.dart';

import 'package:algorand_kmd/src/model/apiv1_delete_key_response.dart';
import 'package:algorand_kmd/src/model/apiv1_delete_multisig_response.dart';
import 'package:algorand_kmd/src/model/apiv1_get_wallets_response.dart';
import 'package:algorand_kmd/src/model/apiv1_post_key_export_response.dart';
import 'package:algorand_kmd/src/model/apiv1_post_key_import_response.dart';
import 'package:algorand_kmd/src/model/apiv1_post_key_list_response.dart';
import 'package:algorand_kmd/src/model/apiv1_post_key_response.dart';
import 'package:algorand_kmd/src/model/apiv1_post_master_key_export_response.dart';
import 'package:algorand_kmd/src/model/apiv1_post_multisig_export_response.dart';
import 'package:algorand_kmd/src/model/apiv1_post_multisig_import_response.dart';
import 'package:algorand_kmd/src/model/apiv1_post_multisig_list_response.dart';
import 'package:algorand_kmd/src/model/apiv1_post_multisig_program_sign_response.dart';
import 'package:algorand_kmd/src/model/apiv1_post_multisig_transaction_sign_response.dart';
import 'package:algorand_kmd/src/model/apiv1_post_program_sign_response.dart';
import 'package:algorand_kmd/src/model/apiv1_post_transaction_sign_response.dart';
import 'package:algorand_kmd/src/model/apiv1_post_wallet_info_response.dart';
import 'package:algorand_kmd/src/model/apiv1_post_wallet_init_response.dart';
import 'package:algorand_kmd/src/model/apiv1_post_wallet_release_response.dart';
import 'package:algorand_kmd/src/model/apiv1_post_wallet_rename_response.dart';
import 'package:algorand_kmd/src/model/apiv1_post_wallet_renew_response.dart';
import 'package:algorand_kmd/src/model/apiv1_post_wallet_response.dart';
import 'package:algorand_kmd/src/model/apiv1_wallet.dart';
import 'package:algorand_kmd/src/model/apiv1_wallet_handle.dart';
import 'package:algorand_kmd/src/model/create_wallet_request.dart';
import 'package:algorand_kmd/src/model/delete_key_request.dart';
import 'package:algorand_kmd/src/model/delete_multisig_request.dart';
import 'package:algorand_kmd/src/model/export_key_request.dart';
import 'package:algorand_kmd/src/model/export_master_key_request.dart';
import 'package:algorand_kmd/src/model/export_multisig_request.dart';
import 'package:algorand_kmd/src/model/generate_key_request.dart';
import 'package:algorand_kmd/src/model/import_key_request.dart';
import 'package:algorand_kmd/src/model/import_multisig_request.dart';
import 'package:algorand_kmd/src/model/init_wallet_handle_token_request.dart';
import 'package:algorand_kmd/src/model/list_keys_request.dart';
import 'package:algorand_kmd/src/model/list_multisig_request.dart';
import 'package:algorand_kmd/src/model/multisig_sig.dart';
import 'package:algorand_kmd/src/model/multisig_subsig.dart';
import 'package:algorand_kmd/src/model/release_wallet_handle_token_request.dart';
import 'package:algorand_kmd/src/model/rename_wallet_request.dart';
import 'package:algorand_kmd/src/model/renew_wallet_handle_token_request.dart';
import 'package:algorand_kmd/src/model/sign_multisig_request.dart';
import 'package:algorand_kmd/src/model/sign_program_multisig_request.dart';
import 'package:algorand_kmd/src/model/sign_program_request.dart';
import 'package:algorand_kmd/src/model/sign_transaction_request.dart';
import 'package:algorand_kmd/src/model/versions_response.dart';
import 'package:algorand_kmd/src/model/wallet_info_request.dart';

part 'serializers.g.dart';

@SerializersFor([
  APIV1DELETEKeyResponse,
  APIV1DELETEMultisigResponse,
  APIV1GETWalletsResponse,
  APIV1POSTKeyExportResponse,
  APIV1POSTKeyImportResponse,
  APIV1POSTKeyListResponse,
  APIV1POSTKeyResponse,
  APIV1POSTMasterKeyExportResponse,
  APIV1POSTMultisigExportResponse,
  APIV1POSTMultisigImportResponse,
  APIV1POSTMultisigListResponse,
  APIV1POSTMultisigProgramSignResponse,
  APIV1POSTMultisigTransactionSignResponse,
  APIV1POSTProgramSignResponse,
  APIV1POSTTransactionSignResponse,
  APIV1POSTWalletInfoResponse,
  APIV1POSTWalletInitResponse,
  APIV1POSTWalletReleaseResponse,
  APIV1POSTWalletRenameResponse,
  APIV1POSTWalletRenewResponse,
  APIV1POSTWalletResponse,
  APIV1Wallet,
  APIV1WalletHandle,
  CreateWalletRequest,
  DeleteKeyRequest,
  DeleteMultisigRequest,
  ExportKeyRequest,
  ExportMasterKeyRequest,
  ExportMultisigRequest,
  GenerateKeyRequest,
  ImportKeyRequest,
  ImportMultisigRequest,
  InitWalletHandleTokenRequest,
  ListKeysRequest,
  ListMultisigRequest,
  MultisigSig,
  MultisigSubsig,
  ReleaseWalletHandleTokenRequest,
  RenameWalletRequest,
  RenewWalletHandleTokenRequest,
  SignMultisigRequest,
  SignProgramMultisigRequest,
  SignProgramRequest,
  SignTransactionRequest,
  VersionsResponse,
  WalletInfoRequest,
])
Serializers serializers = (_$serializers.toBuilder()
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
