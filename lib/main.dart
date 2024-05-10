import 'package:flutter/material.dart';
import 'package:revenue_monster_sdk/home.dart';
import 'package:revenue_monster_sdk/rm-sdk/rm_constants.dart';
import 'package:revenue_monster_sdk/rm-sdk/rm_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await RmSdk().initialize(
    environment: RmEnvironment.sandbox,
    baseUrl: "https://sb-api.revenuemonster.my/demo/payment/online",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revenue Monster SDK',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}
