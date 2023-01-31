///An object that stores a set of tokens.
class TokenPayload {
  ///Tinkoff bank user access token.
  final String accessToken;

  ///Token to get a new access token.
  final String refreshToken;

  TokenPayload({required this.accessToken, required this.refreshToken});

  factory TokenPayload.fromJson(Map<String, dynamic> json) {
    return TokenPayload(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
}
