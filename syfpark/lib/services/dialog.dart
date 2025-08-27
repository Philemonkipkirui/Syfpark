// lib/utils/dialogs.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Dialogs {
  static Future<void> showVehicleDialog(
    BuildContext context,
    String plateNumber,
    Map<String, dynamic>? data,
  ) {
    if (data == null || data.isEmpty) {
      return showErrorDialog(
        context,
        'No information found for $plateNumber.',
      );
    }
    return showVehicleInfoDialog(context, plateNumber, data);
  }

// lib/utils/dialogs.dart (partial, showing showVehicleInfoDialog)
static Future<void> showVehicleInfoDialog(
  BuildContext context,
  String plateNumber,
  Map<String, dynamic> data,
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
              children: data.entries.map<Widget>((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Semantics(
                          label: 'Field name: ${entry.key}',
                          child: Text(
                            '${entry.key}:',
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
                            style: const TextStyle(
                              color: Colors.white70,
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
                    print('Pay Now clicked for $plateNumber');
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
                const SizedBox(width: 32), // Explicit 32px gap
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
    if (value == null || value == 'N/A') return 'N/A';

    if (key == 'TimeIn' || key == 'TimeOut') {
      try {
        final parsedDate = DateTime.parse(value.toString()).toLocal();
        final formatter = DateFormat('dd/MM/yyyy hh:mm a');
        return formatter.format(parsedDate);
      } catch (e) {
        return 'Invalid date';
      }
    }

    return value.toString();
  }
}