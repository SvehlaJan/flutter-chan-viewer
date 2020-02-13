import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:html_unescape/html_unescape.dart';

class ChanUtil {
  var style = '';
  static const int IDEAL_TEXT_LENGTH = 200;
  static const int MAX_TEXT_LENGTH = 300;
  static HtmlUnescape unescaper = HtmlUnescape();

  static getHtml(String raw, bool truncate) {
    var unescaped = unescaper.convert(raw);

    if (unescaped == null) {
      unescaped = 'null';
    } else if (truncate && unescaped.length > IDEAL_TEXT_LENGTH) {
      int idealIndex = max(unescaped.indexOf(RegExp(r'\s'), IDEAL_TEXT_LENGTH), IDEAL_TEXT_LENGTH);
      unescaped = unescaped.substring(0, min(idealIndex, MAX_TEXT_LENGTH)) + "...";
    }

//    var fixed = raw.replaceAll('<br>', '\n');
//    var fixed = raw.replaceAll('class=\"quote\"', 'style=\"color: #789922;\"');
//    if (fixed.contains('<p')) {
//    } else {
//      fixed = '<p style=\"font-size:80%;\">' + fixed + '</p>';
//    }
    return unescaped;
  }

  static String getHumanDate(int timestamp) {
    return formatDate(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
  }
}
