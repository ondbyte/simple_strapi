import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:get/get.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class CategoryX extends X {
  static final i = CategoryX._i();

  CategoryX._i();

  Future<List<BusinessCategory>> init() async {
    final all = await getAllCategories();
    return all;
  }

  Future<List<BusinessCategory>> getAllCategories(
      {bool force = false, Rx? observe}) async {
    return memoize(
      "getAllCategories",
      () async {
        final all = await BusinessCategories.findMultiple();
        return all;
      },
      force: force,
      runWhenChanged: observe,
    );
  }
}
