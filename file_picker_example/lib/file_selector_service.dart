import 'package:file_selector/file_selector.dart';
import 'dart:typed_data';

class FileSelectorService {
  Future<XFile?> openFileDialog() {
    const XTypeGroup typeGroup = XTypeGroup(label: 'any');
    return openFile(acceptedTypeGroups: [typeGroup]);
  }

  Future<FileSaveLocation?> getSaveLocationDialog() {
    return getSaveLocation(suggestedName: 'output.txt');
  }

  Future<void> saveFile(Uint8List data, String path) async {
    final file = XFile.fromData(data, name: 'output.txt');
    await file.saveTo(path);
  }
}
