import 'package:bapp/super_strapi/super_strapi.dart';

class LocalityX {
  static final i = LocalityX._x();

  LocalityX._x() {}

  Future<List<Country>> getCountries() async {
    final countries = await Countries.findMultiple();
    return countries;
  }
}
