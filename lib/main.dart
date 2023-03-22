import 'package:flutter/material.dart';
import 'register-login.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyApplicationId = 'uq3mIDo6JrLvcUXVIr8PUU56gTXbMFtqM2kuPPga';
  final keyClientKey = 'jcYVbSnDf2phLSJJV4RYMb3LgU2t84KUb6vOV0Ge';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SignUp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}