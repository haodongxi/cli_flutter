import 'package:cli_flutter/pages/player_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'IPTV Player',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/player',
      getPages: [
        GetPage(name: '/player', page: () => const PlayerPage()),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
