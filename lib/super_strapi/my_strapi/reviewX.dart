import 'dart:async';

import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:get/get.dart';
import 'package:simple_strapi/simple_strapi.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class ReviewX extends X {
  static final i = ReviewX._i();

  ReviewX._i();

  Future init() async {}

  Future<List<Review>> getReviewsForBusiness(Business business,
      {bool force = false, Rx? observe}) async {
    return memoize(
      "method",
      () async {
        final q = StrapiCollectionQuery(
          collectionName: Review.collectionName,
          requiredFields: Review.fields(),
        )..whereModelField(
            field: Review.fields.booking,
            query: StrapiModelQuery(
              requiredFields: Booking.fields(),
            )
              ..whereModelField(
                field: Booking.fields.business,
                query: StrapiModelQuery(
                  requiredFields: Business.fields(),
                )..whereField(
                    field: Business.fields.id,
                    query: StrapiFieldQuery.equalTo,
                    value: business.id,
                  ),
              )
              ..whereModelField(
                field: Booking.fields.bookedByUser,
                query: StrapiModelQuery(
                  requiredFields: User.fields(),
                ),
              ),
          );
        final reviews = await Reviews.executeQuery(q);
        return reviews;
      },
      force: force,
      runWhenChanged: observe,
    );
  }
}
