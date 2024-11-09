// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:unihack24_vanjo/theme/strings.dart' as strings;

class ApiService {
  final String apiUrl = strings.apiUrl;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    // Create the graphs directory if it doesn't exist
    final graphsDir = Directory('$path/graphs');
    if (!await graphsDir.exists()) {
      await graphsDir.create(recursive: true);
    }
    return '$path/graphs';
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/cycle_image.png');
  }

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

        if (responseData.containsKey('cycle_nodes')) {
          print('Cycle Nodes:');
          List<dynamic> cycleNodes = responseData['cycle_nodes'];
          for (int i = 0; i < cycleNodes.length; i++) {
            print('Node $i: ${cycleNodes[i]}');
          }
        } else {
          print('No cycle_nodes found in response');
        }

        if (responseData.containsKey('cycle_image')) {
          String base64Image = responseData['cycle_image'];

          print('\nEncoded Image (first 100 chars):');
          print(base64Image.substring(0, min(100, base64Image.length)));
          print('Total encoded image length: ${base64Image.length}');

          if (base64Image.contains(',')) {
            base64Image = base64Image.split(',')[1];
            print('Removed data URL prefix');
          }

          base64Image = base64Image.trim();
          base64Image = base64Image.replaceAll('\n', '');
          base64Image = base64Image.replaceAll('\r', '');

          print('Base64 string is valid: ${isValidBase64(base64Image)}');

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
      Uint8List decodedBytes = base64Decode(base64Image);
      print(
          'Successfully decoded base64 to bytes. Size: ${decodedBytes.length} bytes');

      final file = await _localFile;
      await file.writeAsBytes(decodedBytes);

      print('Image saved successfully to: ${file.path}');
    } catch (e) {
      print('Error saving image: $e');
      print('Base64 string length: ${base64Image.length}');
      print(
          'First 100 characters of base64 string: ${base64Image.substring(0, min(100, base64Image.length))}');
    }
  }

  Future<Uint8List?> loadImage() async {
    try {
      final file = await _localFile;

      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        print('Successfully loaded image. Size: ${bytes.length} bytes');
        return bytes;
      } else {
        print('Image file not found at: ${file.path}');
        return null;
      }
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }

  bool isValidBase64(String str) {
    try {
      base64Decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  int min(int a, int b) => a < b ? a : b;
}
