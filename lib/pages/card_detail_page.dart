import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/loyalty_card.dart';

class CardDetailPage extends StatelessWidget {
  final LoyaltyCard card;

  const CardDetailPage({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(card.storeName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(
              title: "Card Information",
              content: [
                DetailRow(label: "Store Name", value: card.storeName),
                DetailRow(label: "Card Number", value: card.cardNumber),
                DetailRow(label: "Barcode", value: card.barcode),
                DetailRow(label: "Cardholder Name", value: card.cardholderName),
                DetailRow(
                  label: "Expiry Date", 
                  value: "${card.expiryDate.day}/${card.expiryDate.month}/${card.expiryDate.year}"
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  const Text(
                    'Show this code at checkout:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  QrImageView(
                    data: card.barcode,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card.barcode,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Increase brightness to maximum while showing the code
                      // You can implement screen brightness control here
                    },
                    icon: const Icon(Icons.brightness_7),
                    label: const Text('Maximize Brightness'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required List<Widget> content,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...content,
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
