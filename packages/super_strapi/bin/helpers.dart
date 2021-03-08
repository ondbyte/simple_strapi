import 'package:code_builder/code_builder.dart';

String toClassName(String s) {
  final l = s.split("-");
  if (l.length > 1) {
    s = "";
    l.forEach((e) {
      s += toClassName(e);
    });
  }
  final ll = s.split("_");
  if (ll.length > 1) {
    s = "";
    ll.forEach((e) {
      s += toClassName(e);
    });
  }
  return s.replaceFirst(s[0], s[0].toUpperCase());
}

String toCamelClassName(String s) {
  return s.replaceFirst(s[0], s[0].toLowerCase());
}
