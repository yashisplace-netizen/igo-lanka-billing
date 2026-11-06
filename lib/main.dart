
import 'package:flutter/material.dart';
import 'invoice_page.dart';
import 'invoice_history_page.dart';
import 'backup_page.dart';

void main() {
  runApp(const IGoLankaApp());
}

class IGoLankaApp extends StatelessWidget {
  const IGoLankaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'I Go Lanka Tours',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087E70),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7F8),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'I Go Lanka Tours',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.account_circle_outlined, size: 28),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Manage your tours, transfers and guest invoices.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const InvoicePage(),
    ),
  );
},
                    icon: const Icon(Icons.add),
                    label: const Text('Create New Invoice'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Manage Your Business',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
  children: [
    Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InvoiceHistoryPage(),
            ),
          );
        },
        child: const DashboardCard(
          icon: Icons.receipt_long,
          title: 'Invoices',
          subtitle: 'View invoice history',
        ),
      ),
    ),
    const SizedBox(width: 12),
    const Expanded(
      child: DashboardCard(
        icon: Icons.people_outline,
        title: 'Guests',
        subtitle: 'Guest records',
      ),
    ),
  ],
),
const SizedBox(height: 12),
Row(
  children: [
    Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BackupPage(),
            ),
          );
        },
        child: const DashboardCard(
          icon: Icons.backup,
          title: 'Backup',
          subtitle: 'Export and restore invoices',
        ),
      ),
    ),
  ],
),
                const SizedBox(height: 28),
                const Card(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF087E70)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your travel billing system is ready to be built.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: const Color(0xFF087E70)),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

