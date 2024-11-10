// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:unihack24_vanjo/theme/strings.dart' as strings;
import 'package:unihack24_vanjo/models/user.dart';

class ApiService {
  final String apiUrl = strings.apiUrl;

  List<String> _cycleNodes = [];
  String? _base64Image;
  List<SkillCycleUser>? _cachedUsers;

  Future<void> fetchCycleData(String userId) async {
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
          _cycleNodes = List<String>.from(responseData['cycle_nodes']);
        } else {
          print('No cycle_nodes found in response');
        }

        if (responseData.containsKey('cycle_image')) {
          _base64Image = responseData['cycle_image'];
          await saveImage(); // Save the image immediately
        } else {
          print('No image found in response');
        }

        // Fetch user details
        _cachedUsers = [];
        for (String userId in _cycleNodes) {
          SkillCycleUser? user = await SkillCycleUser.getUserById(userId);
          if (user != null) {
            _cachedUsers!.add(user);
          } else {
            print('Failed to load user $userId');
          }
        }
      } else {
        print('Failed to load cycle data, status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load cycle data');
      }
    } catch (e, stackTrace) {
      print('Error fetching cycle data: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<SkillCycleUser>> getCachedUsers() async {
    if (_cachedUsers != null) {
      return _cachedUsers!;
    }
    throw Exception('No cached users available. Call fetchCycleData first.');
  }

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

  Future<void> saveImage() async {
    if (_base64Image == null) {
      print('No image data to save');
      return;
    }

    try {
      String base64Image = _base64Image!;

      if (base64Image.contains(',')) {
        base64Image = base64Image.split(',')[1];
      }

      base64Image = base64Image.trim();
      base64Image = base64Image.replaceAll('\n', '');
      base64Image = base64Image.replaceAll('\r', '');

      Uint8List decodedBytes = base64Decode(base64Image);

      final file = await _localFile;
      await file.writeAsBytes(decodedBytes);

      print('Image saved successfully to: ${file.path}');
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  Future<Uint8List?> loadImage() async {
    try {
      final file = await _localFile;

      if (await file.exists()) {
        final bytes = await file.readAsBytes();
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
}