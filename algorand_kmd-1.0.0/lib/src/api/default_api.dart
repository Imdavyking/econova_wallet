//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

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
import 'package:algorand_kmd/src/model/release_wallet_handle_token_request.dart';
import 'package:algorand_kmd/src/model/rename_wallet_request.dart';
import 'package:algorand_kmd/src/model/renew_wallet_handle_token_request.dart';
import 'package:algorand_kmd/src/model/sign_multisig_request.dart';
import 'package:algorand_kmd/src/model/sign_program_multisig_request.dart';
import 'package:algorand_kmd/src/model/sign_program_request.dart';
import 'package:algorand_kmd/src/model/sign_transaction_request.dart';
import 'package:algorand_kmd/src/model/versions_response.dart';
import 'package:algorand_kmd/src/model/wallet_info_request.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

class DefaultApi {
  final Dio _dio;

  final Serializers _serializers;

  const DefaultApi(this._dio, this._serializers);

  Future<Response<APIV1POSTWalletResponse>> createWallet({
    required CreateWalletRequest createWalletRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/wallet';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(CreateWalletRequest);
      _bodyData =
          _serializers.serialize(createWalletRequest, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1POSTWalletResponse _responseData;
    try {
      const _responseType = FullType(APIV1POSTWalletResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1POSTWalletResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1POSTWalletResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1DELETEKeyResponse>> deleteKey({
    required DeleteKeyRequest deleteKeyRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/key';
    final _options = Options(
      method: r'DELETE',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(DeleteKeyRequest);
      _bodyData =
          _serializers.serialize(deleteKeyRequest, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1DELETEKeyResponse _responseData;
    try {
      const _responseType = FullType(APIV1DELETEKeyResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1DELETEKeyResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1DELETEKeyResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1DELETEMultisigResponse>> deleteMultisig({
    required DeleteMultisigRequest deleteMultisigRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/multisig';
    final _options = Options(
      method: r'DELETE',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(DeleteMultisigRequest);
      _bodyData =
          _serializers.serialize(deleteMultisigRequest, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1DELETEMultisigResponse _responseData;
    try {
      const _responseType = FullType(APIV1DELETEMultisigResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1DELETEMultisigResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1DELETEMultisigResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1POSTKeyExportResponse>> exportKey({
    required ExportKeyRequest exportKeyRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/key/export';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(ExportKeyRequest);
      _bodyData =
          _serializers.serialize(exportKeyRequest, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1POSTKeyExportResponse _responseData;
    try {
      const _responseType = FullType(APIV1POSTKeyExportResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1POSTKeyExportResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1POSTKeyExportResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1POSTMasterKeyExportResponse>> exportMasterKey({
    required ExportMasterKeyRequest exportMasterKeyRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/master-key/export';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(ExportMasterKeyRequest);
      _bodyData =
          _serializers.serialize(exportMasterKeyRequest, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1POSTMasterKeyExportResponse _responseData;
    try {
      const _responseType = FullType(APIV1POSTMasterKeyExportResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1POSTMasterKeyExportResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1POSTMasterKeyExportResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1POSTMultisigExportResponse>> exportMultisig({
    required ExportMultisigRequest exportMultisigRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/multisig/export';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(ExportMultisigRequest);
      _bodyData =
          _serializers.serialize(exportMultisigRequest, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1POSTMultisigExportResponse _responseData;
    try {
      const _responseType = FullType(APIV1POSTMultisigExportResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1POSTMultisigExportResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1POSTMultisigExportResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1POSTKeyResponse>> generateKey({
    required GenerateKeyRequest generateKeyRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/key';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(GenerateKeyRequest);
      _bodyData =
          _serializers.serialize(generateKeyRequest, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1POSTKeyResponse _responseData;
    try {
      const _responseType = FullType(APIV1POSTKeyResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1POSTKeyResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1POSTKeyResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<VersionsResponse>> getVersion({
    JsonObject? versionsRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/versions';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      _bodyData = versionsRequest;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    VersionsResponse _responseData;
    try {
      const _responseType = FullType(VersionsResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as VersionsResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<VersionsResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1POSTWalletInfoResponse>> getWalletInfo({
    required WalletInfoRequest getWalletInfoRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/wallet/info';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(WalletInfoRequest);
      _bodyData =
          _serializers.serialize(getWalletInfoRequest, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1POSTWalletInfoResponse _responseData;
    try {
      const _responseType = FullType(APIV1POSTWalletInfoResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1POSTWalletInfoResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1POSTWalletInfoResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1POSTKeyImportResponse>> importKey({
    required ImportKeyRequest importKeyRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/key/import';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(ImportKeyRequest);
      _bodyData =
          _serializers.serialize(importKeyRequest, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1POSTKeyImportResponse _responseData;
    try {
      const _responseType = FullType(APIV1POSTKeyImportResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1POSTKeyImportResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1POSTKeyImportResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1POSTMultisigImportResponse>> importMultisig({
    required ImportMultisigRequest importMultisigRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/multisig/import';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(ImportMultisigRequest);
      _bodyData =
          _serializers.serialize(importMultisigRequest, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1POSTMultisigImportResponse _responseData;
    try {
      const _responseType = FullType(APIV1POSTMultisigImportResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1POSTMultisigImportResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1POSTMultisigImportResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1POSTWalletInitResponse>> initWalletHandleToken({
    required InitWalletHandleTokenRequest initializeWalletHandleTokenRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/wallet/init';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(InitWalletHandleTokenRequest);
      _bodyData = _serializers.serialize(initializeWalletHandleTokenRequest,
          specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1POSTWalletInitResponse _responseData;
    try {
      const _responseType = FullType(APIV1POSTWalletInitResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1POSTWalletInitResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1POSTWalletInitResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1POSTKeyListResponse>> listKeysInWallet({
    required ListKeysRequest listKeysRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/key/list';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(ListKeysRequest);
      _bodyData = _serializers.serialize(listKeysRequest, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1POSTKeyListResponse _responseData;
    try {
      const _responseType = FullType(APIV1POSTKeyListResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1POSTKeyListResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1POSTKeyListResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1POSTMultisigListResponse>> listMultisg({
    required ListMultisigRequest listMultisigRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/multisig/list';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(ListMultisigRequest);
      _bodyData =
          _serializers.serialize(listMultisigRequest, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1POSTMultisigListResponse _responseData;
    try {
      const _responseType = FullType(APIV1POSTMultisigListResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1POSTMultisigListResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1POSTMultisigListResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1GETWalletsResponse>> listWallets({
    JsonObject? listWalletRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/wallets';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      _bodyData = listWalletRequest;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1GETWalletsResponse _responseData;
    try {
      const _responseType = FullType(APIV1GETWalletsResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1GETWalletsResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1GETWalletsResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1POSTWalletReleaseResponse>> releaseWalletHandleToken({
    required ReleaseWalletHandleTokenRequest releaseWalletHandleTokenRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/wallet/release';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(ReleaseWalletHandleTokenRequest);
      _bodyData = _serializers.serialize(releaseWalletHandleTokenRequest,
          specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1POSTWalletReleaseResponse _responseData;
    try {
      const _responseType = FullType(APIV1POSTWalletReleaseResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1POSTWalletReleaseResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1POSTWalletReleaseResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1POSTWalletRenameResponse>> renameWallet({
    required RenameWalletRequest renameWalletRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/wallet/rename';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(RenameWalletRequest);
      _bodyData =
          _serializers.serialize(renameWalletRequest, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1POSTWalletRenameResponse _responseData;
    try {
      const _responseType = FullType(APIV1POSTWalletRenameResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1POSTWalletRenameResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1POSTWalletRenameResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1POSTWalletRenewResponse>> renewWalletHandleToken({
    required RenewWalletHandleTokenRequest renewWalletHandleTokenRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/wallet/renew';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(RenewWalletHandleTokenRequest);
      _bodyData = _serializers.serialize(renewWalletHandleTokenRequest,
          specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1POSTWalletRenewResponse _responseData;
    try {
      const _responseType = FullType(APIV1POSTWalletRenewResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1POSTWalletRenewResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1POSTWalletRenewResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1POSTMultisigProgramSignResponse>> signMultisigProgram({
    required SignProgramMultisigRequest signMultisigProgramRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/multisig/signprogram';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(SignProgramMultisigRequest);
      _bodyData = _serializers.serialize(signMultisigProgramRequest,
          specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1POSTMultisigProgramSignResponse _responseData;
    try {
      const _responseType = FullType(APIV1POSTMultisigProgramSignResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1POSTMultisigProgramSignResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1POSTMultisigProgramSignResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1POSTMultisigTransactionSignResponse>>
      signMultisigTransaction({
    required SignMultisigRequest signMultisigTransactionRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/multisig/sign';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(SignMultisigRequest);
      _bodyData = _serializers.serialize(signMultisigTransactionRequest,
          specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1POSTMultisigTransactionSignResponse _responseData;
    try {
      const _responseType = FullType(APIV1POSTMultisigTransactionSignResponse);
      _responseData = _serializers.deserialize(_response.data!,
              specifiedType: _responseType)
          as APIV1POSTMultisigTransactionSignResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1POSTMultisigTransactionSignResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1POSTProgramSignResponse>> signProgram({
    required SignProgramRequest signProgramRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/program/sign';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(SignProgramRequest);
      _bodyData =
          _serializers.serialize(signProgramRequest, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1POSTProgramSignResponse _responseData;
    try {
      const _responseType = FullType(APIV1POSTProgramSignResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1POSTProgramSignResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1POSTProgramSignResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<APIV1POSTTransactionSignResponse>> signTransaction({
    required SignTransactionRequest signTransactionRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/transaction/sign';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );
    dynamic _bodyData;
    try {
      const _type = FullType(SignTransactionRequest);
      _bodyData =
          _serializers.serialize(signTransactionRequest, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _options.compose(_dio.options, _path),
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    final _response = await _dio.request<Object>(_path,
        data: _bodyData,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    APIV1POSTTransactionSignResponse _responseData;
    try {
      const _responseType = FullType(APIV1POSTTransactionSignResponse);
      _responseData = _serializers.deserialize(_response.data!,
          specifiedType: _responseType) as APIV1POSTTransactionSignResponse;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<APIV1POSTTransactionSignResponse>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }

  Future<Response<String>> swaggerHandler({
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/swagger.json';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'api_key',
            'keyName': 'X-KMD-API-Token',
            'where': 'header'
          }
        ],
        ...?extra
      },
      validateStatus: validateStatus,
    );
    final _response = await _dio.request<Object>(_path,
        options: _options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    String _responseData;
    try {
      _responseData = _response.data as String;
    } catch (error, stackTrace) {
      throw DioException(
          requestOptions: _response.requestOptions,
          response: _response,
          type: DioExceptionType.unknown,
          error: error,
          stackTrace: stackTrace);
    }
    return Response<String>(
        data: _responseData,
        headers: _response.headers,
        isRedirect: _response.isRedirect,
        requestOptions: _response.requestOptions,
        redirects: _response.redirects,
        statusCode: _response.statusCode,
        statusMessage: _response.statusMessage,
        extra: _response.extra);
  }
}
