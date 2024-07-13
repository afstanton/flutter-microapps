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
  FilePickerHomeState createState() => FilePickerHomeState();
}

class FilePickerHomeState extends State<FilePickerHome> {
  Uint8List? fileContent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Picker Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _readFile,
              child: const Text('Read'),
            ),
            ElevatedButton(
              onPressed: fileContent == null ? null : _writeFile,
              child: const Text('Write'),
            ),
            if (fileContent != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'File Content: ${fileContent!.length} bytes',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _readFile() async {
    const typeGroup = XTypeGroup(label: 'any', extensions: []);
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      final content = await file.readAsBytes();
      setState(() {
        fileContent = content;
      });
    }
  }

  Future<void> _writeFile() async {
    if (fileContent == null) return;

    if (kIsWeb) {
      final fileName = await _promptFileName();
      if (fileName != null) {
        _downloadFileWeb(fileContent!, fileName);
        print('File written successfully to web.');
      }
    } else {
      final saveLocation = await getSaveLocation(
        acceptedTypeGroups: [const XTypeGroup(label: 'any', extensions: [])],
      );
      if (saveLocation != null) {
        final path = saveLocation.path;
        final file = XFile.fromData(fileContent!, name: path.split('/').last);
        await file.saveTo(path);
        print('File written successfully to: $path');
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
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
