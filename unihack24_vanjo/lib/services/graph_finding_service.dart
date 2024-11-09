// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiUrl = 'http://192.168.30.218:5000/find_cycle';

  Future<Map<String, dynamic>?> sendRequest(String docId) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'doc_id': docId}),
      );

      if (response.statusCode == 200) {
        print('Success: ${response.body}');
        return json.decode(response.body);
      } else {
        print('Error: Status code ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error: $e');
      return null;
    }
  }
}

class MyApp extends StatelessWidget {
  final ApiService apiService = ApiService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: MyHomePage(apiService: apiService),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final ApiService apiService;

  const MyHomePage({super.key, required this.apiService});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;
  String _response = '';

  Future<void> _sendRequest() async {
    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      final result =
          await widget.apiService.sendRequest("csVOh0iOC9XP0kpuEhNnyu1FBQP2");

      setState(() {
        _response =
            result != null ? json.encode(result) : 'Failed to get response';
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter API Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _isLoading ? null : _sendRequest,
                child: const Text('Send Request'),
              ),
            const SizedBox(height: 20),
            if (_response.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _response,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
