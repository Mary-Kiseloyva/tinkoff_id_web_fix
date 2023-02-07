## Features

The package allows you to receive a set of social tokens from the Tinkoff ID system of Tinkoff Bank.

## Getting started

Android requirements:

- compileSdkVersion >= 32
- minSdkVersion >= 19

## Usage

```dart
class TinkoffIdWebViewScreen extends StatelessWidget {
  const TinkoffIdWebViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: tinkoffYellow,
      ),
      body: TinkoffIdWebView(
        clientId: 'youClientId',
        mobileRedirectUri: 'tmr://tinkoff-mobile-redirect',
        clearCookies: true,
        showProgressIndicator: true,
        onWebViewFinished: (result) {
          if (result.isSuccess) {
            print(result.tokenPayload.accessToken);
            print(result.tokenPayload.refreshToken);
          } else {
            print(result.message);
            switch (result.failureValue) {
              case TinkoffIdFailure.cancelledByUser:
              // TODO: Handle this case.
                break;
              case TinkoffIdFailure.webResourceError:
              // TODO: Handle this case.
                break;
              case TinkoffIdFailure.noCodeInRedirectUri:
              // TODO: Handle this case.
                break;
              case TinkoffIdFailure.apiCallError:
              // TODO: Handle this case.
                break;
            }
          }
        },
        
      ),
    );
  }
}
```

## Additional information

For more information, support, or to report bugs or suggest new features.
https://github.com/kodefabrique/tinkoff_id_web


