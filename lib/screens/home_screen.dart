import 'package:flutter/material.dart';
import 'package:inventory_manage/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              buildCard(
                context,
                icon: Icons.widgets,
                title: "Sản phẩm",
                color: Colors.green,
                onTap: () => Navigator.pushNamed(context, AppRoutes.product),
              ),
              buildCard(
                context,
                icon: Icons.input_outlined,
                title: "Nhập hàng",
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(context, AppRoutes.import_),
              ),
              buildCard(
                context,
                icon: Icons.sell,
                title: "Bán hàng",
                color: Colors.red,
                onTap: () => Navigator.pushNamed(context, AppRoutes.sale),
              ),
              buildCard(
                context,
                icon: Icons.bar_chart,
                title: "Báo cáo",
                color: Colors.purple,
                onTap: () => Navigator.pushNamed(context, AppRoutes.statistic),
              ),
              buildCard(
                context,
                icon: Icons.barcode_reader,
                title: "Quét mã",
                color: Colors.lightBlueAccent,
                onTap: () => Navigator.pushNamed(context, AppRoutes.scan),
              ),
              buildCard(
                context,
                icon: Icons.account_circle,
                title: "Tài khoản",
                color: Colors.grey,
                onTap: () => Navigator.pushNamed(context, AppRoutes.user),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 33),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
    ),
  );
}
