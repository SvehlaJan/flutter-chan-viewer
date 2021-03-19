import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:flutter_chan_viewer/utils/extensions.dart';

class ChanUtil {
  var style = '';
  static const int IDEAL_TEXT_LENGTH = 200;
  static const int MAX_TEXT_LENGTH = 300;
  static HtmlUnescape unescaper = HtmlUnescape();

  static String unescapeHtml(String raw) => unescaper.convert(raw ?? "");

  static String getReadableHtml(String htmlContent, bool truncate) {
    if (htmlContent == null) {
      htmlContent = 'null';
    } else if (truncate && htmlContent.length > IDEAL_TEXT_LENGTH) {
      int idealIndex = max(htmlContent.indexOf(RegExp(r'\s'), IDEAL_TEXT_LENGTH), IDEAL_TEXT_LENGTH);
      htmlContent = htmlContent.substring(0, min(idealIndex, MAX_TEXT_LENGTH)) + "...";
    }
    return htmlContent;
  }

  static String getPlainString(String htmlContent) {
    String rawContent = "";
    if (htmlContent.isNotNullNorEmpty) {
      Document document = parse(htmlContent.replaceAll("<br>", " ").replaceAll("</p><p>", " "));
      rawContent = parse(document.body.text).documentElement.text;
    }
    return rawContent;
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

  static int getNowTimestamp() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }
}
