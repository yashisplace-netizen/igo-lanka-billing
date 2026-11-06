import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


Future<void> generateInvoicePdf(Map<String, dynamic> invoice) async {
  final pdf = pw.Document();

  final services = (invoice['services'] as List?) ?? [];
  final currency = invoice['currency']?.toString() ?? 'USD';
  final total = (invoice['total'] as num?)?.toDouble() ?? 0.0;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        pw.Text(
          'I GO LANKA TOURS',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.teal800,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text('95/B, Kalapuraya, Sigiriya, Sri Lanka'),
        pw.Text('WhatsApp: +94772621276'),
        pw.Text('Email: igolankatours@gmail.com'),
        pw.Text('Website: www.igolanka.com'),
        pw.Divider(),
        pw.SizedBox(height: 15),
        pw.Text(
          'INVOICE',
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Text('Invoice No: ${invoice['invoiceNumber'] ?? ''}'),
        pw.Text('Date: ${invoice['date'] ?? ''}'),
        pw.SizedBox(height: 15),
        pw.Text(
          'GUEST DETAILS',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text('Name: ${invoice['guestName'] ?? ''}'),
        pw.Text('Country: ${invoice['guestCountry'] ?? ''}'),
        pw.Text('WhatsApp: ${invoice['guestPhone'] ?? ''}'),
        pw.Text('Email: ${invoice['guestEmail'] ?? ''}'),
        pw.SizedBox(height: 20),
        pw.Text(
          'SERVICES',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: ['Service', 'Description', 'Price'],
          data: services.map((service) {
            final item = Map<String, dynamic>.from(service as Map);
            final price = (item['price'] as num?)?.toDouble() ?? 0.0;

            return [
  item['type']?.toString() ?? '',
  [
    if (item['type'] == 'Hotel Accommodation') ...[
      'Hotel: ${item['hotelName'] ?? ''}',
      'Details: ${item['description'] ?? ''}',
      'Check-in: ${item['checkIn'] ?? ''}',
      'Check-out: ${item['checkOut'] ?? ''}',
      'Total Nights: ${item['nights'] ?? 0}',
    ] else if (item['type'] == 'Activities & Experiences') ...[
      'Activity: ${item['activityName'] ?? ''}',
      'Date: ${item['activityDate'] ?? ''}',
      'Participants: ${item['participants'] ?? ''}',
      'Details: ${item['description'] ?? ''}',
    ] else ...[
      item['description']?.toString() ?? '',
    ],
  ].join('\n'),
  '$currency ${price.toStringAsFixed(2)}',
];
          }).toList(),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(
            color: PdfColors.teal800,
          ),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.all(8),
        ),
        pw.SizedBox(height: 20),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'TOTAL: $currency ${total.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal800,
            ),
          ),
        ),
        pw.SizedBox(height: 40),
        pw.Center(
          child: pw.Text(
            'Thank you for choosing I Go Lanka Tours!',
            style: pw.TextStyle(
              fontSize: 12,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ),
      ],
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}