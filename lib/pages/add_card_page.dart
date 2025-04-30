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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          'Add Loyalty Card',
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: theme.colorScheme.primary,
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.credit_card,
                    size: 64,
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add New Card',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: _storeNameController,
                      label: 'Store Name',
                      icon: Icons.store,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _cardNumberController,
                      label: 'Card Number',
                      icon: Icons.credit_card,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _barcodeController,
                      label: 'Barcode',
                      icon: Icons.qr_code,
                      suffix: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: _startScanning,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _cardholderNameController,
                      label: 'Cardholder Name',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          _expiryDate == null
                              ? 'Select Expiry Date'
                              : 'Expires: ${_expiryDate?.day}/${_expiryDate?.month}/${_expiryDate?.year}',
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 3650)),
                          );
                          if (date != null) {
                            setState(() => _expiryDate = date);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Add Card',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please enter $label' : null,
    );
  }

  Widget _buildScanner() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        color: Colors.black,
      ),
      child: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                setState(() {
                  _barcodeController.text = barcode.rawValue ?? '';
                  _cardNumberController.text = barcode.rawValue ?? '';
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Barcode scanned successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                break;
              }
            },
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Scan barcode or QR code',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
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
