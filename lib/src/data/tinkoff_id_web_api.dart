import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tinkoff_id_web/src/entities/token_payload.dart';

/// Api interface for requesting tinkoff backend
abstract class TinkoffIdWebApi {
  /// Exchanges the code and the verifier code for tokens.
  Future<TokenPayload> changeCodeForTokens(
    String clientId,
    String mobileRedirectUri,
    String code,
    String codeVerifier,
  );
}

/// Api interface  implementation
class TinkoffIdWebApiImpl implements TinkoffIdWebApi {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "https://id.tinkoff.ru/",
    connectTimeout: 8000,
    receiveTimeout: 8000,
  ));

  TinkoffIdWebApiImpl() {
    _dio.interceptors.addAll([
      if (!kReleaseMode)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (m) => log(m.toString()),
        ),
    ]);
  }

  @override
  Future<TokenPayload> changeCodeForTokens(
    String clientId,
    String mobileRedirectUri,
    String code,
    String codeVerifier,
  ) async {
    final response = await _dio.post(
      "auth/token",
      data: {
        "grant_type": "authorization_code",
        "redirect_uri": mobileRedirectUri,
        "code": code,
        "code_verifier": codeVerifier,
      },
      options: Options(
        responseType: ResponseType.json,
        headers: {
          "Authorization": "Basic " + base64Encode(utf8.encode(clientId)),
        },
        contentType: "application/x-www-form-urlencoded",
      ),
    );
    return TokenPayload.fromJson(response.data);
  }
}
