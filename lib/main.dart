import 'package:flutter/material.dart';

import 'features/poc/poc_screen.dart';

void main() {
  runApp(const MessageParserApp());
}

class MessageParserApp extends StatelessWidget {
  const MessageParserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Message Parser',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const PocScreen(),
    );
  }
}
