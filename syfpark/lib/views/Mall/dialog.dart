import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syfpark/views/Mall/payment.dart';

class Dialogs {
  // Map raw keys to user-friendly labels for display
  static const Map<String, String> _keyToLabel = {
    'plateNumber': 'Plate Number',
    'timeIn': 'Time In',
    'timeOut': 'Time Out',
    'parkingLocation': 'Location',
    'timeInMinutes': 'Duration (min)',
    'amountPaid': 'Amount Payable',
  };

  static Future<void> showVehicleDialog(
    BuildContext context,
    String plateNumber,
    Map<String, dynamic>? data,
    String vehicleApiUrl,
    String paymentApiUrl,
  ) {
    if (data == null || data.isEmpty || data['details']?.isEmpty != false) {
      return showErrorDialog(
        context,
        'No information found for $plateNumber.',
      );
    }
    return showVehicleInfoDialog(context, plateNumber, data, paymentApiUrl);
  }

  static Future<void> showVehicleInfoDialog(
    BuildContext context,
    String plateNumber,
    Map<String, dynamic> data,
    String paymentApiUrl,
  ) {
    final details = data['details'][0];
    return showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: ThemeData.dark().copyWith(
            dialogBackgroundColor: Colors.black,
            textTheme: const TextTheme(
              headlineSmall: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              bodyMedium: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          child: AlertDialog(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Semantics(
              label: 'Vehicle information dialog title for $plateNumber',
              child: Text(
                'Vehicle: $plateNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: details.entries.map<Widget>((entry) {
                  final displayLabel = _keyToLabel[entry.key] ?? entry.key; // Use mapped label or fallback to raw key
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Semantics(
                            label: 'Field name: $displayLabel',
                            child: Text(
                              '$displayLabel:',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Semantics(
                            label: 'Field value: ${_formatEntryValue(entry.key, entry.value)}',
                            child: Text(
                              _formatEntryValue(entry.key, entry.value),
                              style: TextStyle(
                                color: entry.value != null && entry.value != 'null' ? Colors.white70 : Colors.redAccent,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPage(
                            plateNumber: plateNumber,
                            vehicleData: data,
                            paymentApiUrl: paymentApiUrl,
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Pay Now'),
                  ),
                  const SizedBox(width: 32),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showErrorDialog(
    BuildContext context,
    String message,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: ThemeData.dark().copyWith(
            dialogBackgroundColor: Colors.black,
            textTheme: const TextTheme(
              headlineSmall: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              bodyMedium: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          child: AlertDialog(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Error',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            content: Text(
              message,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _formatEntryValue(String key, dynamic value) {
    if (value == null || value == 'null') {
      return key == 'amountPaid' ? 'none' : 'N/A';
    }
    if (key == 'timeIn' || key == 'timeOut') {
      try {
        final parsedDate = DateTime.parse(value.toString()).toLocal();
        final formatter = DateFormat('dd/MM/yyyy hh:mm a');
        return formatter.format(parsedDate);
      } catch (e) {
        return 'Invalid date';
      }
    }
    if (key == 'amountPaid') {
      return NumberFormat.currency(symbol: 'KES ').format(double.parse(value.toString()));
    }
    return value.toString();
  }
}