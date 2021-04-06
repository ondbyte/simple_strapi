import 'package:bapp/helpers/helper.dart';
import 'package:bapp/super_strapi/my_strapi/partnerX.dart';
import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:flutter/foundation.dart';
import 'package:get/state_manager.dart';
import 'package:simple_strapi/simple_strapi.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BusinessX extends X {
  static final i = BusinessX._x();
  BusinessX._x();

  final businesses = <Business>[].obs;

  Future<List<Business>> init() async {
    final partner = PartnerX.i.partner();
    if (partner is Partner) {
      await getPartnerBusinessesFromServer(
        partner,
        force: true,
      );
    }
    return businesses;
  }

  Future<List<Business>> getPartnerBusinessesFromServer(
    Partner partner, {
    bool force = false,
    Rx? observe,
  }) async {
    final all = await memoize(
      "_getPartnerBusinessesFromServer",
      () async {
        final ids = partner.businesses?.map((e) => e.id) ?? [];
        if (isNullOrEmpty(ids)) {
          bPrint("partner doesnt have businesses");
          return <Business>[];
        }
        return <Business>[];
      },
      force: force,
      runWhenChanged: observe,
    );
    businesses.clear();
    businesses.addAll(all);
    return businesses;
  }

  Future<List<Business>> getNearestBusinesses({
    BusinessCategory? forCategory,
    bool force = false,
    Rx? observe,
  }) async {
    final q = StrapiCollectionQuery(
      collectionName: Business.collectionName,
      requiredFields: Business.fields(),
    );
    return memoize(
      "getNearestBusinesses",
      () async {
        if (forCategory is BusinessCategory) {
          q.whereModelField(
            field: Business.fields.business_category,
            query: StrapiModelQuery(
              requiredFields: BusinessCategory.fields(),
            )..whereField(
                field: BusinessCategory.fields.name,
                query: StrapiFieldQuery.equalTo,
                value: forCategory.name,
              ),
          );
        }
        final found = await Businesses.executeQuery(q);
        return found;
      },
      force: force,
      runWhenChanged: observe,
    );
  }

  @override
  Future dispose() async {
    super.dispose();
  }
}
