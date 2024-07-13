import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:typed_data';

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
}
