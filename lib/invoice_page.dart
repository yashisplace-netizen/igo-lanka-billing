
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class InvoicePage extends StatefulWidget {
  final Map<String, dynamic>? invoice;

  const InvoicePage({super.key, this.invoice});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final guestName = TextEditingController();
  final guestCountry = TextEditingController();
  final guestPhone = TextEditingController();
  final guestEmail = TextEditingController();

  String currency = 'USD';
  String serviceType = 'Private Driver Tour (Round Tour)';

  final List<String> serviceTypes = [
    'Airport Transfer',
    'One-way Transfer',
    'Private Driver Tour (Round Tour)',
    'Jeep Safari',
    'Hotel Accommodation',
    'Activities & Experiences',
    'Other Service',
  ];

    final List<Map<String, dynamic>> services = [];

  @override
  void initState() {
    super.initState();

    final existingInvoice = widget.invoice;

    if (existingInvoice != null) {
      guestName.text = existingInvoice['guestName'] ?? '';
      guestCountry.text = existingInvoice['guestCountry'] ?? '';
      guestPhone.text = existingInvoice['guestPhone'] ?? '';
      guestEmail.text = existingInvoice['guestEmail'] ?? '';
      currency = existingInvoice['currency'] ?? 'USD';

      final savedServices = existingInvoice['services'] as List? ?? [];

      for (final item in savedServices) {
        services.add(Map<String, dynamic>.from(item as Map));
      }

      if (services.isNotEmpty) {
        serviceType = services.first['type']?.toString() ?? serviceType;
      }
    }
  }

  void addService() {
  setState(() {
    services.add({
      'type': serviceType,
      'description': '',
      'hotelName': '',
      'checkIn': '',
      'checkOut': '',
      'nights': '',
      'activityName': '',
      'activityDate': '',
      'participants': '',
      'price': 0.0,
    });
  });
}
Future<void> _saveInvoice() async {
  if (guestName.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter the guest name.')),
    );
    return;
  }

  if (services.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please add at least one service.')),
    );
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  final savedInvoices = prefs.getStringList('saved_invoices') ?? [];

    final invoiceNumber = widget.invoice?['invoiceNumber'] ??
      'IGL-${DateTime.now().millisecondsSinceEpoch}';

  final invoice = {
    'invoiceNumber': invoiceNumber,
    'date': widget.invoice?['date'] ?? DateTime.now().toIso8601String(),
    'guestName': guestName.text.trim(),
    'guestCountry': guestCountry.text.trim(),
    'guestPhone': guestPhone.text.trim(),
    'guestEmail': guestEmail.text.trim(),
    'currency': currency,
    'services': services,
    'total': total,
  };

  if (widget.invoice != null) {
    final index = savedInvoices.indexWhere((saved) {
      final existing = jsonDecode(saved);
      return existing['invoiceNumber'] == invoiceNumber;
    });

    if (index != -1) {
      savedInvoices[index] = jsonEncode(invoice);
    }
  } else {
    savedInvoices.add(jsonEncode(invoice));
  }

  await prefs.setStringList('saved_invoices', savedInvoices);

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Invoice saved successfully!')),
  );
}
  double get total {
    return services.fold(
      0.0,
      (sum, item) => sum + (item['price'] as double),
    );
  }

  @override
  void dispose() {
    guestName.dispose();
    guestCountry.dispose();
    guestPhone.dispose();
    guestEmail.dispose();
    super.dispose();
  }

  Widget inputField(
    String label,
    TextEditingController controller,
    {TextInputType keyboard = TextInputType.text}
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  int calculateNights(String checkIn, String checkOut) {
    final formats = [
      RegExp(r'^\s*(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})\s*$'),
      RegExp(r'^\s*(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})\s*$'),
    ];

    DateTime? parseDate(String value) {
      final match = formats[0].firstMatch(value);
      if (match == null) return null;

      const months = {
        'january': 1, 'february': 2, 'march': 3,
        'april': 4, 'may': 5, 'june': 6,
        'july': 7, 'august': 8, 'september': 9,
        'october': 10, 'november': 11, 'december': 12,
      };

      final month = months[match.group(2)!.toLowerCase()];
      if (month == null) return null;

      return DateTime(
        int.parse(match.group(3)!),
        month,
        int.parse(match.group(1)!),
      );
    }

    final start = parseDate(checkIn);
    final end = parseDate(checkOut);

    if (start == null || end == null || !end.isAfter(start)) {
      return 0;
    }

    return end.difference(start).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Invoice'),
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
                  'Guest Information',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                inputField('Guest Full Name', guestName),
                inputField('Country / Nationality', guestCountry),
                inputField(
                  'WhatsApp Number',
                  guestPhone,
                  keyboard: TextInputType.phone,
                ),
                inputField(
                  'Email Address',
                  guestEmail,
                  keyboard: TextInputType.emailAddress,
                ),
                const Divider(height: 35),
                const Text(
                  'Invoice Currency',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: currency,
                  decoration: const InputDecoration(
                    labelText: 'Select Currency',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: ['USD', 'EUR', 'LKR'].map((value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => currency = value);
                    }
                  },
                ),
                const Divider(height: 35),
                const Text(
                  'Tours, Transfers & Other Services',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: serviceType,
                  decoration: const InputDecoration(
                    labelText: 'Service Type',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: serviceTypes.map((value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => serviceType = value);
                    }
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: addService,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Service'),
                  ),
                ),
                const SizedBox(height: 14),
                ...services.asMap().entries.map((entry) {
                  final index = entry.key;
                  final service = entry.value;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service['type'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (service['type'] == 'Hotel Accommodation') ...[
  TextFormField(
    initialValue: service['hotelName'] ?? '',
    decoration: const InputDecoration(
      labelText: 'Hotel Name',
      border: OutlineInputBorder(),
    ),
    onChanged: (value) {
      service['hotelName'] = value;
    },
  ),
  const SizedBox(height: 10),
  TextFormField(
    initialValue: service['description'] ?? '',
    maxLines: 3,
    decoration: const InputDecoration(
      labelText: 'Room Category / Meal Plan / Other Details',
      border: OutlineInputBorder(),
    ),
    onChanged: (value) {
      service['description'] = value;
    },
  ),
  const SizedBox(height: 10),
  TextFormField(
    initialValue: service['checkIn'] ?? '',
    decoration: const InputDecoration(
      labelText: 'Check-in Date (e.g. 10 Jan 2027)',
      border: OutlineInputBorder(),
    ),
    onChanged: (value) {
      setState(() {
        service['checkIn'] = value;
        service['nights'] = calculateNights(
          value,
          service['checkOut'] ?? '',
        );
      });
    },
  ),
  const SizedBox(height: 10),
  TextFormField(
    initialValue: service['checkOut'] ?? '',
    decoration: const InputDecoration(
      labelText: 'Check-out Date (e.g. 12 Jan 2027)',
      border: OutlineInputBorder(),
    ),
    onChanged: (value) {
      setState(() {
        service['checkOut'] = value;
        service['nights'] = calculateNights(
          service['checkIn'] ?? '',
          value,
        );
      });
    },
  ),
  const SizedBox(height: 10),
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      'Total Nights: ${service['nights'] ?? 0}',
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
] else if (service['type'] == 'Activities & Experiences') ...[
  TextFormField(
    initialValue: service['activityName'] ?? '',
    decoration: const InputDecoration(
      labelText: 'Activity Name',
      border: OutlineInputBorder(),
    ),
    onChanged: (value) {
      service['activityName'] = value;
    },
  ),
  const SizedBox(height: 10),
  TextFormField(
    initialValue: service['activityDate'] ?? '',
    decoration: const InputDecoration(
      labelText: 'Activity Date',
      border: OutlineInputBorder(),
    ),
    onChanged: (value) {
      service['activityDate'] = value;
    },
  ),
  const SizedBox(height: 10),
  TextFormField(
    initialValue: service['participants'] ?? '',
    keyboardType: TextInputType.number,
    decoration: const InputDecoration(
      labelText: 'Number of Participants',
      border: OutlineInputBorder(),
    ),
    onChanged: (value) {
      service['participants'] = value;
    },
  ),
  const SizedBox(height: 10),
  TextFormField(
    initialValue: service['description'] ?? '',
    maxLines: 2,
    decoration: const InputDecoration(
      labelText: 'Additional Details',
      border: OutlineInputBorder(),
    ),
    onChanged: (value) {
      service['description'] = value;
    },
  ),
] else ...[
  TextFormField(
    initialValue: service['description'] ?? '',
    decoration: const InputDecoration(
      labelText: 'Description / Itinerary',
      border: OutlineInputBorder(),
    ),
    onChanged: (value) {
      service['description'] = value;
    },
  ),
],
                          const SizedBox(height: 10),
                          TextFormField(
                            initialValue: '0',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Price ($currency)',
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                service['price'] =
                                    double.tryParse(value) ?? 0.0;
                              });
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() => services.removeAt(index));
                              },
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Remove'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const Divider(height: 35),
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
                SizedBox(
  width: double.infinity,
  child: FilledButton.icon(
    onPressed: _saveInvoice,
    icon: const Icon(Icons.save),
    label: const Text('Save Invoice'),
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF087E70),
      padding: const EdgeInsets.symmetric(vertical: 16),
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
