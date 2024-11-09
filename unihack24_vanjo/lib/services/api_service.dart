// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:unihack24_vanjo/theme/strings.dart' as strings;

class ApiService {
  final String apiUrl = strings.apiUrl;

  Future<void> fetchAndSaveImage(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/find_cycle'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'doc_id': userId}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey('cycle_image')) {
          // Changed from 'encoded_image' to 'cycle_image'
          String base64Image = responseData['cycle_image'];

          // Remove potential data URL prefix if present
          if (base64Image.contains(',')) {
            base64Image = base64Image.split(',')[1];
          }

          // Clean the base64 string
          base64Image = base64Image.trim();
          base64Image = base64Image.replaceAll('\n', '');
          base64Image = base64Image.replaceAll('\r', '');

          await saveImage(base64Image);
        } else {
          print('No image found in response');
          print('Response data: $responseData');
        }
      } else {
        print('Failed to load image, status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error fetching image: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> saveImage(String base64Image) async {
    try {
      // Decode the base64 string to bytes
      Uint8List decodedBytes = base64Decode(base64Image);

      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/cycle_image.png';

      // Save the decoded image
      final file = File(imagePath);
      await file.writeAsBytes(decodedBytes);

      print('Image saved successfully to: $imagePath');
    } catch (e) {
      print('Error saving image: $e');
      print('Base64 string length: ${base64Image.length}');
      print(
          'First 100 characters of base64 string: ${base64Image.substring(0, min(100, base64Image.length))}');
    }
  }

  Future<Uint8List?> loadImage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/cycle_image.png';
      final file = File(imagePath);

      if (await file.exists()) {
        return await file.readAsBytes();
      } else {
        print('Image file not found at: $imagePath');
        return null;
      }
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }

  // Utility function to check if a string is valid base64
  bool isValidBase64(String str) {
    try {
      base64Decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Helper function to get minimum of two numbers
  int min(int a, int b) => a < b ? a : b;
}
