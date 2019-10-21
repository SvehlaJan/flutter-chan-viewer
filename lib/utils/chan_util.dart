import 'dart:math';

class ChanUtil {
  var style = '';

  static getHtml(String raw) {
    if (raw == null) {
      raw = 'null';
    } else {
      raw = raw.substring(0, min(raw.length, 200));
    }
    var test = raw.replaceAll('<br>', '\n').replaceAll('class=\"quote\"', 'style=\"color: #789922;\"');
    if (test.contains('<p')) {
    } else {
      test = '<p style=\"font-size:80%;\">' + test + '</p>';
    }
    var res = test;
    return res;
//    return raw;
  }
}
