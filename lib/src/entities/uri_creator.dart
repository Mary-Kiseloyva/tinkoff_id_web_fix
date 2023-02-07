import 'package:pkce/pkce.dart';

///An object that generates a code verifier and a link to open in the WebView.
class UriCreator {
  ///An object for checking the code on the backend side.
  late final String codeVerifier;

  UriCreator();

  ///Webview link generation method.
  Uri createUri(String clientId, mobileRedirectUri) {
    if (clientId.isEmpty || mobileRedirectUri.isEmpty) {
      final message =
          "clientId: $clientId or mobileRedirectUri: $mobileRedirectUri is empty";
      throw Exception(message);
    }

    final pkcePair = PkcePair.generate(length: 64);
    codeVerifier = pkcePair.codeVerifier;

    final uri = Uri.https(
      "id.tinkoff.ru",
      "/auth/authorize",
      {
        "client_id": clientId,
        "redirect_uri": mobileRedirectUri,
        "code_verifier": pkcePair.codeVerifier,
        "code_challenge": pkcePair.codeChallenge,
        "code_challenge_method": "S256",
        "response_type": "code",
        "response_mode": "query"
      },
    );
    return uri;
  }
}
