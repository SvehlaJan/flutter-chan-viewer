import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ChanCache {
  static final ChanCache _repo = new ChanCache._internal();

  static ChanCache get() {
    return _repo;
  }

  ChanCache._internal() {
    // initialization code
  }



  Future<String> _readString(String filePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}$filePath');
      String text = await file.readAsString();
      return text;
    } catch (e) {
      print("Couldn't read file $filePath");
      return null;
    }
  }

  _saveString(String filePath, String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}$filePath');
    await file.writeAsString(content);
    print('String file saved successfully $filePath');
  }
}