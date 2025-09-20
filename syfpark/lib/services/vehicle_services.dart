import 'dart:convert';
import 'package:http/http.dart' as http;

class VehicleService {
  static Future<Map<String, dynamic>?> fetchVehicleInfo(String plateNumber, String vehicleinfo_apiUrl) async {
    try {
      final url = Uri.parse(vehicleinfo_apiUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'carnumber': plateNumber}),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic> || !decoded.containsKey('details')) {
          print('Unexpected JSON format: $decoded');
          return null;
        }

        final details = decoded['details'] as List<dynamic>;
        if (details.isEmpty) {
          print('No vehicle data found in response');
          return null;
        }

        final vehicleData = details[0] as Map<String, dynamic>;
        final requiredKeys = ['plateNumber', 'timeIn', 'timeOut', 'parkingLocation', 'timeInMinutes', 'amountPaid'];
        for (var key in requiredKeys) {
          if (!vehicleData.containsKey(key)) {
            print('Warning: key "$key" missing from response.');
          }
        }

        return decoded; // Return the full decoded response
      } else {
        print('API returned status code: ${response.statusCode}');
        return null;
      }
    } catch (e, stack) {
      print('Error fetching vehicle info: $e');
      print(stack);
      return null;
    }
  }
}