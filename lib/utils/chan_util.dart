import 'dart:math';

import 'package:date_format/date_format.dart';

class ChanUtil {
  var style = '';
  static const int IDEAL_TEXT_LENGTH = 200;
  static const int MAX_TEXT_LENGTH = 300;

  static getHtml(String raw) {
    if (raw == null) {
      raw = 'null';
    } else if (raw.length > IDEAL_TEXT_LENGTH) {
      int idealIndex = max(raw.indexOf(RegExp(r'\s'), IDEAL_TEXT_LENGTH), IDEAL_TEXT_LENGTH);
      raw = raw.substring(0, min(idealIndex, MAX_TEXT_LENGTH)) + "...";
    }

    var fixed = raw.replaceAll('<br>', '\n').replaceAll('class=\"quote\"', 'style=\"color: #789922;\"');
    if (fixed.contains('<p')) {
    } else {
      fixed = '<p style=\"font-size:80%;\">' + fixed + '</p>';
    }
    return fixed;
  }

  static String getHumanDate(int timestamp) {
    return formatDate(DateTime.fromMillisecondsSinceEpoch(timestamp), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
  }
}
