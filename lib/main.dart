import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vigenesia/Screen/Login.dart';
import 'package:vigenesia/Provider/UserProvider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // tambahkan provider lainnya jika diperlukan
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}
