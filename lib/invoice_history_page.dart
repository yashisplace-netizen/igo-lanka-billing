import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'invoice_pdf.dart';
import 'invoice_page.dart';

class InvoiceHistoryPage extends StatefulWidget {
  const InvoiceHistoryPage({super.key});

  @override
  State<InvoiceHistoryPage> createState() => _InvoiceHistoryPageState();
}

class _InvoiceHistoryPageState extends State<InvoiceHistoryPage> {
  List<Map<String, dynamic>> invoices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final savedInvoices = prefs.getStringList('saved_invoices') ?? [];

    final loadedInvoices = <Map<String, dynamic>>[];

    for (final item in savedInvoices) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map<String, dynamic>) {
          loadedInvoices.add(decoded);
        }
      } catch (_) {
        // Skip invalid saved invoices.
      }
    }

    if (!mounted) return;

    setState(() {
      invoices = loadedInvoices.reversed.toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice History'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: loadInvoices,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : invoices.isEmpty
              ? const Center(child: Text('No saved invoices yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    final guestName =
                        invoice['guestName']?.toString() ?? 'Unknown Guest';
                    final invoiceNumber =
                        invoice['invoiceNumber']?.toString() ?? '';
                    final currency =
                        invoice['currency']?.toString() ?? '';
                    final total =
                        (invoice['total'] as num?)?.toDouble() ?? 0.0;

                    final dateText = invoice['date']?.toString() ?? '';
                    final date = DateTime.tryParse(dateText);
                    final formattedDate = date == null
                        ? dateText
                        : '${date.day.toString().padLeft(2, '0')}/'
                          '${date.month.toString().padLeft(2, '0')}/'
                          '${date.year}';

                    return Card(
  color: Colors.white,
  margin: const EdgeInsets.only(bottom: 12),
  child: ListTile(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InvoiceDetailsPage(invoice: invoice),
        ),
      );
    },
    leading: const CircleAvatar(
      backgroundColor: Color(0xFFE0F2EF),
      child: Icon(
        Icons.receipt_long,
        color: Color(0xFF087E70),
      ),
    ),
    title: Text(
      guestName,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    subtitle: Text('$invoiceNumber\n$formattedDate'),
    isThreeLine: true,
    trailing: Text(
      '$currency ${total.toStringAsFixed(2)}',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF087E70),
      ),
    ),
  ),
);     
             },
                ),
    );
  }
}
class InvoiceDetailsPage extends StatefulWidget {
  final Map<String, dynamic> invoice;

  const InvoiceDetailsPage({super.key, required this.invoice});

    @override
  State<InvoiceDetailsPage> createState() => _InvoiceDetailsPageState();
}

class _InvoiceDetailsPageState extends State<InvoiceDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final services = (widget.invoice['services'] as List?) ?? [];
    final currency = widget.invoice['currency']?.toString() ?? '';
final total = (widget.invoice['total'] as num?)?.toDouble() ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'I Go Lanka Tours',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF087E70),
                  ),
                ),
                const SizedBox(height: 8),
const SizedBox(height: 15),

SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () async {
      await generateInvoicePdf(widget.invoice);
    },
    icon: const Icon(Icons.picture_as_pdf),
    label: const Text('Download PDF Invoice'),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF087E70),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15),
    ),
  ),
),
SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InvoicePage(invoice: widget.invoice),
        ),
      );
    },
    icon: const Icon(Icons.edit),
    label: const Text('Edit Invoice'),
  ),
),
const SizedBox(height: 10),
const SizedBox(height: 15),
                Text('Invoice No: ${widget.invoice['invoiceNumber'] ?? ''}'),
                Text('Date: ${widget.invoice['date'] ?? ''}'),
                const Divider(height: 30),
                const Text(
                  'Guest Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text('Name: ${widget.invoice['guestName'] ?? ''}'),
                Text('Country: ${widget.invoice['guestCountry'] ?? ''}'),
                Text('WhatsApp: ${widget.invoice['guestPhone'] ?? ''}'),
                Text('Email: ${widget.invoice['guestEmail'] ?? ''}'),
                const Divider(height: 30),
                const Text(
                  'Services',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ...services.map((item) {
                  final service = Map<String, dynamic>.from(item as Map);
                  final price =
                      (service['price'] as num?)?.toDouble() ?? 0.0;

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service['type']?.toString() ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (service['type'] == 'Hotel Accommodation') ...[
                            Text('Hotel: ${service['hotelName'] ?? ''}'),
                            Text('Details: ${service['description'] ?? ''}'),
                            Text('Check-in: ${service['checkIn'] ?? ''}'),
                            Text('Check-out: ${service['checkOut'] ?? ''}'),
                            Text('Total Nights: ${service['nights'] ?? 0}'),
                          ] else
                            Text(service['description']?.toString() ?? ''),
                          const SizedBox(height: 8),
                          Text(
                            '$currency ${price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF087E70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Invoice Total',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$currency ${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF087E70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
