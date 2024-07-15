import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(CatFactsApp(client: http.Client()));
}

class CatFactsApp extends StatelessWidget {
  final http.Client client;

  const CatFactsApp({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cat Facts App'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CatFactsScreen(client: client),
        ),
      ),
    );
  }
}

class CatFactsScreen extends StatefulWidget {
  final http.Client client;

  const CatFactsScreen({super.key, required this.client});

  @override
  _CatFactsScreenState createState() => _CatFactsScreenState();
}

class _CatFactsScreenState extends State<CatFactsScreen> {
  String _catFact = 'Press the button to get a cat fact!';

  Future<void> _getCatFact() async {
    final response =
        await widget.client.get(Uri.parse('https://catfact.ninja/fact'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _catFact = data['fact'];
      });
    } else {
      setState(() {
        _catFact = 'Failed to get a cat fact';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          _catFact,
          style: const TextStyle(fontSize: 18.0),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: _getCatFact,
          child: const Text('Get Cat Fact'),
        ),
      ],
    );
  }
}
