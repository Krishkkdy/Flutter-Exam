import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/loyalty_card.dart';
import '../services/card_service.dart';
import '../services/auth_service.dart';

class AddCardPage extends StatefulWidget {
  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  final CardService _cardService = CardService();
  final AuthService _authService = AuthService();

  final _storeNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _cardholderNameController = TextEditingController();
  DateTime? _expiryDate;
  final _scannerController = MobileScannerController();
  bool _isScanning = false;

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              setState(() {
                _barcodeController.text = barcode.rawValue ?? '';
                _cardNumberController.text = barcode.rawValue ?? '';
                _isScanning = false;
              });
              Navigator.of(context).pop(); // Close scanner
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Barcode scanned successfully')),
              );
              break;
            }
          },
        ),
        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              setState(() => _isScanning = false);
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }

  void _startScanning() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: _buildScanner(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Loyalty Card'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _storeNameController,
              decoration: const InputDecoration(labelText: 'Store Name'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter store name' : null,
            ),
            TextFormField(
              controller: _cardNumberController,
              decoration: const InputDecoration(labelText: 'Card Number'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter card number' : null,
            ),
            TextFormField(
              controller: _barcodeController,
              decoration: InputDecoration(
                labelText: 'Barcode',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _startScanning,
                ),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter barcode' : null,
            ),
            TextFormField(
              controller: _cardholderNameController,
              decoration: const InputDecoration(labelText: 'Cardholder Name'),
              validator: (value) => value?.isEmpty ?? true
                  ? 'Please enter cardholder name'
                  : null,
            ),
            ListTile(
              title: Text(_expiryDate == null
                  ? 'Select Expiry Date'
                  : 'Expiry Date: ${_expiryDate?.toString().split(' ')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (date != null) {
                  setState(() => _expiryDate = date);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Add Card'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_expiryDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select expiry date')),
        );
        return;
      }

      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first')),
        );
        return;
      }

      final card = LoyaltyCard(
        id: const Uuid().v4(),
        storeName: _storeNameController.text,
        cardNumber: _cardNumberController.text,
        barcode: _barcodeController.text,
        cardholderName: _cardholderNameController.text,
        expiryDate: _expiryDate!,
        userId: userId,
      );

      try {
        await _cardService.addCard(card);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding card: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _cardNumberController.dispose();
    _barcodeController.dispose();
    _cardholderNameController.dispose();
    _scannerController.dispose();
    super.dispose();
  }
}
