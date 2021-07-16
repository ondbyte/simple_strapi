import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class UpdateX extends X {
  static late UpdateX i;
  UpdateX._i();

  factory UpdateX() {
    final i = UpdateX._i();
    UpdateX.i = i;
    return i;
  }

  Future<List<Update>> getAllCategories({Key? key, Rx? observe}) async {
    return memoize(
      key ?? ValueKey("getAllCategories"),
      () async {
        return await Updates.findMultiple();
      },
      runWhenChanged: observe,
    );
  }
}
