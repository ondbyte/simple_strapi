import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class CategoryX extends X {
  static final i = CategoryX._i();

  CategoryX._i();

  Future<List<BusinessCategory>> getAllCategories(
      {Key? key, Rx? observe}) async {
    return memoize(
      key ?? ValueKey("getAllCategories"),
      () async {
        return await BusinessCategories.findMultiple();
      },
      runWhenChanged: observe,
    );
  }
}
