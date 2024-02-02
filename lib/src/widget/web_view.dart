import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tinkoff_id_web/src/data/tinkoff_id_web_api.dart';
import 'package:tinkoff_id_web/src/entities/failure_value.dart';
import 'package:tinkoff_id_web/src/entities/result.dart';
import 'package:tinkoff_id_web/src/entities/uri_creator.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Tinkoff design yellow color
const tinkoffYellow = Color(0xFFFFDD2D);

///Tinkoff Id WebView Widget
class TinkoffIdWebView extends StatefulWidget {
  /// Client ID given during registration.
  final String clientId;

  /// Mobile redirect uri that you set during registration
  final String mobileRedirectUri;

  /// Whether to enter the user's phone number each time or remember it.
  final bool clearCookies;

  /// Whether to show a progress indicator when the first page is loaded or not.
  final bool showProgressIndicator;

  ///A function that is called when the login succeeds or fails.
  final Function(TinkoffIdResult result) onWebViewFinished;

  const TinkoffIdWebView({
    Key? key,
    required this.onWebViewFinished,
    required this.clientId,
    required this.mobileRedirectUri,
    this.clearCookies = false,
    this.showProgressIndicator = false,
  }) : super(key: key);

  @override
  State<TinkoffIdWebView> createState() => _TinkoffIdWebViewState();
}

class _TinkoffIdWebViewState extends State<TinkoffIdWebView> {
  late final WebViewController _webViewController;
  late final UriCreator _uriCreator;
  late final TinkoffIdWebApi _tinkoffIdWebApi = TinkoffIdWebApiImpl();
  final tinkoffUrl = 'https://www.tinkoff.ru/';

  bool _isLoading = true;

  @override
  void initState() {
    _uriCreator = UriCreator();
    final uri = _uriCreator.createUri(widget.clientId, widget.mobileRedirectUri);
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            ///Ios anti fix
            if (Platform.isAndroid) {
              ///Android fix
              if (request.url.contains("https://id.tinkoff.ru/auth/step?cid")) {
                _webViewController.loadRequest(Uri.parse(request.url));
                return NavigationDecision.prevent;
              }
            }

            if (request.url.contains("${tinkoffUrl}tinkoff-id")) {
              return NavigationDecision.navigate;
            } else if (request.url.contains(tinkoffUrl)) {
              _onFinished(TinkoffIdResult.failure("Cancelled by user.", TinkoffIdFailure.cancelledByUser));
              return NavigationDecision.prevent;
            }
            if (request.url.contains(widget.mobileRedirectUri)) {
              _processSuccessUrl(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) async {
            if (url.contains(uri.toString())) {
              _setLoading(true);
            }
          },
          onPageFinished: (String url) {
            _setLoading(false);
          },
          onWebResourceError: (WebResourceError error) async {
            ///ios fix
            if ((await _webViewController.currentUrl())?.contains("https://id.tinkoff.ru/auth/step?cid") ?? true) {
              return;
            }
            _onFinished(TinkoffIdResult.failure(error.description, TinkoffIdFailure.webResourceError));
          },
        ),
      );
    if (widget.clearCookies) {
      WebViewCookieManager().clearCookies();
    }
    Future.delayed(
      const Duration(milliseconds: 200),
      () => _webViewController.loadRequest(uri),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _onFinished(TinkoffIdResult.failure("Cancelled by user.", TinkoffIdFailure.cancelledByUser));
        return Future(() => false);
      },
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(
                  controller: _webViewController,
                ),
                if (widget.showProgressIndicator)
                  Visibility(
                    visible: _isLoading,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: tinkoffYellow,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _processSuccessUrl(String url) async {
    final queryParameters = Uri.parse(url).queryParameters;
    final code = queryParameters["code"];
    if (code?.isNotEmpty ?? false) {
      try {
        final tokenPayload = await _tinkoffIdWebApi.changeCodeForTokens(
          widget.clientId,
          widget.mobileRedirectUri,
          code!,
          _uriCreator.codeVerifier,
        );
        _onFinished(TinkoffIdResult.success(tokenPayload));
      } catch (e) {
        _onFinished(TinkoffIdResult.failure(e.toString(), TinkoffIdFailure.apiCallError));
      }
    } else {
      _onFinished(TinkoffIdResult.failure(
        "Отсутствует код проверки",
        TinkoffIdFailure.noCodeInRedirectUri,
      ));
    }
  }

  _onFinished(TinkoffIdResult result) => widget.onWebViewFinished(result);

  _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }
}
