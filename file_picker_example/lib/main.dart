import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

void main() {
  runApp(const FilePickerExample());
}

class FilePickerExample extends StatelessWidget {
  const FilePickerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FilePickerHome(),
    );
  }
}

class FilePickerHome extends StatefulWidget {
  const FilePickerHome({super.key});

  @override
  _FilePickerHomeState createState() => _FilePickerHomeState();
}

class _FilePickerHomeState extends State<FilePickerHome> {
  // Pre-populate the variable with "Hello, world."
  Uint8List fileContent = Uint8List.fromList('Hello, world.'.codeUnits);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Picker Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _writeFile,
          child: const Text('Write'),
        ),
      ),
    );
  }

  Future<void> _writeFile() async {
    if (kIsWeb) {
      final filename = await _promptFileName();
      if (filename != null) {
        _downloadFileWeb(fileContent, filename);
      }
    } else {
      const XTypeGroup typeGroup = XTypeGroup(label: 'any', extensions: ['*']);
      final saveLocation = await getSaveLocation(suggestedName: 'output.txt');
      if (saveLocation != null) {
        final file = XFile.fromData(fileContent, name: 'output.txt');
        await file.saveTo(saveLocation.path);
      }
    }
  }

  Future<String?> _promptFileName() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String fileName = '';
        return AlertDialog(
          title: const Text('Enter file name'),
          content: TextField(
            onChanged: (value) {
              fileName = value;
            },
            decoration: const InputDecoration(hintText: "File name"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(fileName);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _downloadFileWeb(Uint8List data, String filename) {
    final blob = html.Blob([data]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
