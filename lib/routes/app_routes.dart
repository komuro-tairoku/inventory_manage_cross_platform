import 'package:flutter/material.dart';
import 'package:inventory_manage/screens/product_screen.dart';
import 'package:inventory_manage/screens/import_screen.dart';
import 'package:inventory_manage/screens/sale_screen.dart';
import 'package:inventory_manage/screens/statistic_screen.dart';
import 'package:inventory_manage/screens/scan_screen.dart';
import 'package:inventory_manage/screens/user_screen.dart';

class AppRoutes {
  static const String product = '/product';
  static const String import_ = '/import';
  static const String sale = '/sale';
  static const String statistic = '/statistic';
  static const String scan = '/scan';
  static const String user = '/user';

  static Map<String, WidgetBuilder> get routes => {
    product: (_) => const ProductScreen(),
    import_: (_) => const ImportScreen(),
    sale: (_) => const SaleScreen(),
    statistic: (_) => const StatisticScreen(),
    scan: (_) => const ScanScreen(),
    user: (_) => const UserScreen(),
  };
}
