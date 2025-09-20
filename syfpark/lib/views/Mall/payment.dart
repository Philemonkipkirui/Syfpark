import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syfpark/services/payment_services.dart';
import 'package:syfpark/views/home/constants.dart';
import 'package:intl/intl.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final String plateNumber;
  final Map<String, dynamic> vehicleData;
  final String paymentApiUrl;

  const PaymentPage({
    super.key,
    required this.plateNumber,
    required this.vehicleData,
    required this.paymentApiUrl,
  });

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final TextEditingController _phoneController = TextEditingController();
  String? _errorMessage;

  Future<void> _initiatePayment() async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty || !RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
      setState(() {
        _errorMessage = 'Please enter a valid 10-digit mobile number';
      });
      return;
    }

    try {
      setState(() {
        _errorMessage = null;
      });
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      final response = await PaymentService.initiateMPesaPayment(
        plateNumber: widget.plateNumber,
        phoneNumber: phoneNumber,
        paymentApiUrl: widget.paymentApiUrl,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();

      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['transactionId'] != null
                ? 'Payment initiated successfully. Transaction ID: ${response['transactionId']}. Check your phone for STK push.'
                : 'Payment initiated successfully. Check your phone for STK push.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      setState(() {
        _errorMessage = '$e';
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.vehicleData['details']?.isNotEmpty == true
        ? widget.vehicleData['details'][0]
        : null;
    final amount = details != null ? details['amountPaid']?.toString() : null;
    final formattedAmount = amount != null && amount != 'null'
        ? NumberFormat.currency(symbol: 'KES ').format(double.parse(amount))
        : 'none';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle: ${widget.plateNumber}',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Amount Payable: $formattedAmount',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: amount != null && amount != 'null' ? Colors.white70 : Colors.redAccent,
                          ),
                    ),
                    if (amount == null || amount == 'null')
                      Text(
                        'No payment required at this time.',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.redAccent,
                              fontSize: 14,
                            ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'MPesa',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              enabled: amount != null && amount != 'null',
              decoration: InputDecoration(
                hintText: 'Enter (e.g., 0712345675)',
                hintStyle: const TextStyle(color:AppColors.textUnselected),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                errorText: _errorMessage,
                errorStyle: const TextStyle(color: Colors.redAccent),
              ),
              style: const TextStyle(color:AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: amount != null && amount != 'null' ? _initiatePayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Pay Now', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}