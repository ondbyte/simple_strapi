Future main() async {
  print(_collectionNameToGraphQlName("Users"));
}

String _collectionNameToGraphQlName(
  String collectionName,
) {
  final all = collectionName.split(RegExp(r'[\s_-]'));
  final from2nd = all.sublist(1);
  var returnable = "" + all[0];
  from2nd.forEach((s) {
    returnable += _capitalizeFirst(s);
  });
  return returnable;
}

String _capitalizeFirst(String s) {
  final f = s.split("").first;
  return s.replaceFirst(
    f,
    f.toUpperCase(),
  );
}
