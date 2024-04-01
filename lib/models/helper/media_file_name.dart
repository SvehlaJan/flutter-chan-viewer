import 'package:path/path.dart';

class MediaFileName {
  String name;
  String extension;

  MediaFileName(this.name, this.extension);

  factory MediaFileName.fromPath(String filePath) {
    final fileName = basename(filePath);
    int dotIndex = fileName.lastIndexOf(".");
    if (dotIndex == -1) {
      return MediaFileName(fileName, "");
    }
    return MediaFileName(fileName.substring(0, dotIndex), fileName.substring(dotIndex + 1));
  }

  @override
  String toString() {
    return "$name$extension";
  }
}
