import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:html/dom.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:html/parser.dart';

class ChanUtil {
  var style = '';
  static const int IDEAL_TEXT_LENGTH = 200;
  static const int MAX_TEXT_LENGTH = 300;
  static HtmlUnescape unescaper = HtmlUnescape();

  static unescapeHtml(String raw) => unescaper.convert(raw ?? "");

  static getReadableHtml(String content, bool truncate) {
    if (content == null) {
      content = 'null';
    } else if (truncate && content.length > IDEAL_TEXT_LENGTH) {
      int idealIndex = max(content.indexOf(RegExp(r'\s'), IDEAL_TEXT_LENGTH), IDEAL_TEXT_LENGTH);
      content = content.substring(0, min(idealIndex, MAX_TEXT_LENGTH)) + "...";
    }
    return content;
  }

  static List<int> getPostReferences(String content) {
    Document document = parse(content ?? "");
    List<Element> links = document.querySelectorAll('body > a');
//    List<Map<String, dynamic>> linkMap = [];
    List<int> postIds = [];

    for (var link in links) {
      int replyTo = getPostIdFromUrl(link.attributes['href']);
      if (replyTo != null) {
        postIds.add(replyTo);
      }
//      linkMap.add({
//        'title': link.text,
//        'href': link.attributes['href'],
//      });
    }

    return postIds;
  }

  static int getPostIdFromUrl(String url) => url.startsWith("#p") ? int.parse(url.substring(2)) : null;

  static String getHumanDate(int timestamp) {
    return formatDate(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000), [mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
  }
}
