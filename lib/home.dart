import 'package:flutter/material.dart';
import 'package:revenue_monster_sdk/rm-sdk/rm_constants.dart';
import 'package:revenue_monster_sdk/rm-sdk/rm_sdk.dart';

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
