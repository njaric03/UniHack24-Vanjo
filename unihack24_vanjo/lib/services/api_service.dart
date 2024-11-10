// api_service.dart

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

  /// Registers a user with the API.
  Future<bool> registerUserWithApi(SkillCycleUser user) async {
    try {
      final url = Uri.parse('$apiUrl/add_user');

      final payload = {
        "doc_id": user.id,
        "attributes": {
          "first_name": user.firstName,
          "last_name": user.lastName,
          "teaching_subject": user.teachingSubjects!.isNotEmpty
              ? user.teachingSubjects!.first
              : "",
          "learning_subject": user.learningSubjects!.isNotEmpty
              ? user.learningSubjects!.first
              : "",
          "rating_avg_teacher": user.ratingAvg,
          "avatar_id": user.avatarId,
        }
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print("API Success: ${response.body}");
        return true;
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("API Exception: $e");
      return false;
    }
  }

  /// Fetches cycle data for a given user ID.
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
          await saveImage();
        } else {
          print('No image found in response');
        }

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

  /// Returns the cached users.
  Future<List<SkillCycleUser>> getCachedUsers() async {
    if (_cachedUsers != null) {
      return _cachedUsers!;
    }
    throw Exception('No cached users available. Call fetchCycleData first.');
  }

  /// Returns the local path for storing images.
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final graphsDir = Directory('$path/graphs');
    if (!await graphsDir.exists()) {
      await graphsDir.create(recursive: true);
    }
    return '$path/graphs';
  }

  /// Returns the local file for storing the cycle image.
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/cycle_image.png');
  }

  /// Saves the cycle image to local storage.
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

  /// Loads the cycle image from local storage.
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
