import 'package:flutter/material.dart';
import 'package:inventory_manage/screens/home_screen.dart';
import 'package:inventory_manage/routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Manage',
      debugShowCheckedModeBanner: false,
      // ❌ Bỏ: home: const HomeScreen(),
      initialRoute: '/', // ← thêm dòng này
      routes: {
        '/': (_) => const HomeScreen(), // ← thêm route cho home
        ...AppRoutes.routes, // ← spread các route còn lại
      },
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}
