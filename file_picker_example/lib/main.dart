import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'file_selector_service.dart';

void main() {
  runApp(const FilePickerExample());
}

class FilePickerExample extends StatelessWidget {
  const FilePickerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FilePickerHome(fileSelectorService: FileSelectorService()),
    );
  }
}

class FilePickerHome extends StatefulWidget {
  final FileSelectorService fileSelectorService;

  const FilePickerHome({super.key, required this.fileSelectorService});

  @override
  _FilePickerHomeState createState() => _FilePickerHomeState();
}

class _FilePickerHomeState extends State<FilePickerHome> {
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
          ],
        ),
      ),
    );
  }

  Future<void> _readFile() async {
    final file = await widget.fileSelectorService.openFileDialog();
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
      final filename = await _promptFileName();
      if (filename != null) {
        _downloadFileWeb(fileContent!, filename);
      }
    } else {
      final saveLocation =
          await widget.fileSelectorService.getSaveLocationDialog();
      if (saveLocation != null) {
        await widget.fileSelectorService
            .saveFile(fileContent!, saveLocation.path);
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
