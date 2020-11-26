
import 'package:thephonenumber/thecountrynumber.dart';

main() async {
  final tmp = TheCountryNumber().parseNumber(iso2Code: "IN");
  print(tmp.toString());
}

