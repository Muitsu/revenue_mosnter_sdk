

# Revenue Monster SDK
`Publisher:` [`Muitsu`]()

`Version:` [`0.0.1`]()

A flutter plugin for Revenue Monster SDK.

This plugin contains a set of high-level functions and classes that make it easy to have seamless in-app transactions, secure digital payments, It's multi-platform, and works on both `Android` and `iOS`.

## Installation

Use this package as a library

Go to the `pubspec.yaml` directory

```yaml
dependencies:
  flutter:
    sdk: flutter
  wallet_sdk:
     git:
       url: https://test/sds
       ref: master
```

Then run this on terminal

```bash
flutter pub get
```

Import it

Now in your Dart code, you can use:

```dart
import 'package:rm_sdk/rm_sdk.dart';
```
## Getting Started

We tried to make RM SDK as simple to use as possible:

```dart
Future <void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
    await RmSdk().initialize(
        environment: RmEnvironment.sandbox,
        baseUrl: "https://sb-api.revenuemonster.my/demo/payment/online");
   runApp(const MyApp());
}

```

First we start with initializing the sdk using `RmSdk().initialize` function with selected environment. There are 2 environment to choose.

- `SANDBOX:` **RmEnvironment.sandbox**
- `PRODUCTION:` **RmEnvironment.sandbox**


## How to use

To use our plugin you have to define payment details inside `RmSdk().launchSDK` function

```dart
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("RM SDK"),
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () async {
                await RmSdk().launchSDK(
                  method: RMPaymentMethod.grabpay,
                  total: 120,
                  onSuccess: () {},
                  onFailed: () {},
                  onCancelled: () {},
                  onTimeout: () {},
                );
              },
              child: const Text("Test Run SDK"))
        ],
      ),
    );
  }
}


```
Once the user details is define everything is set up.
## Features & Configurations

- Initialize SDK

```dart
RmSdk().initialize(....)
```

- Set payment details

```dart
    RmSdk().launchSDK(
         method: RMPaymentMethod.grabpay,
         total: 120,
         onSuccess: () {},
         onFailed: () {},
         onCancelled: () {},
        onTimeout: () {},
    );
```

## Supported payment method

- `FPX:` **RMPaymentMethod.fpx**
- `GrabPay:` **RMPaymentMethod.grabpay**

