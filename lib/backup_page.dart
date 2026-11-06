import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  Future<void> exportBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final invoices = prefs.getStringList('saved_invoices') ?? [];

    if (invoices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No invoices available to back up.')),
      );
      return;
    }

    final backupData = jsonEncode({
      'app': 'I Go Lanka Tours',
      'backupDate': DateTime.now().toIso8601String(),
      'invoices': invoices.map((item) => jsonDecode(item)).toList(),
    });

    await FileSaver.instance.saveFile(
      name: 'igo_lanka_invoices_backup',
      bytes: utf8.encode(backupData),
      ext: 'json',
      mimeType: MimeType.json,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup file downloaded successfully.')),
    );
  }

  Future<void> restoreBackup() async {
    final result = await FilePicker.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['json'],
  withData: true,
);

    if (result == null) return;

    try {
      final bytes = result.files.single.bytes;
      if (bytes == null) {
        throw Exception('Could not read the selected file.');
      }

      final data = jsonDecode(utf8.decode(bytes));
      if (data is! Map || data['invoices'] is! List) {
        throw Exception('Invalid backup file.');
      }

      final invoices = (data['invoices'] as List)
          .map((item) => jsonEncode(item))
          .toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('saved_invoices', invoices);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${invoices.length} invoices restored successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Backup'),
        backgroundColor: const Color(0xFF087E70),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.backup,
                  size: 80,
                  color: Color(0xFF087E70),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Protect Your Invoices',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Download a backup of all your invoices or restore them from a previous backup file.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: exportBackup,
                    icon: const Icon(Icons.download),
                    label: const Text('Export All Invoices'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF087E70),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: restoreBackup,
                    icon: const Icon(Icons.restore),
                    label: const Text('Restore Invoices'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
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