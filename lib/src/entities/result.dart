import 'failure_value.dart';
import 'token_payload.dart';

///The result of the login.
class TinkoffIdResult {
  ///Login success.
  late final bool isSuccess;

  ///A set of tokens if successful.
  late final TokenPayload tokenPayload;

  ///Message on failure.
  late final String message;

  ///Type of reason for failure.
  late final TinkoffIdFailure failureValue;

  ///Success constructor.
  TinkoffIdResult.success(this.tokenPayload) {
    isSuccess = true;
  }

  ///Failed result constructor.
  TinkoffIdResult.failure(this.message, this.failureValue) {
    isSuccess = false;
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'Result{isSuccess: $isSuccess, value: ${tokenPayload.toString()}';
    } else {
      return 'Result{isSuccess: $isSuccess, message: $message}';
    }
  }
}
