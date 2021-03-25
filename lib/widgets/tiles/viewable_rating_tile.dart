import 'package:bapp/classes/firebase_structures/rating.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/booking_flow/review.dart';
import 'package:bapp/super_strapi/super_strapi.dart';
import 'package:flutter/material.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class ViewableRating extends StatelessWidget {
  final EdgeInsets? padding;
  final bool showReview;
  final Review review;
  final Function()? onTap;

  ViewableRating({
    this.showReview = true,
    required this.review,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              review.booking?.bookedByUser?.name ??
                  "no user name present inform yadu",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(
              height: 10,
            ),
            BappRatingBar(
              onRatingUpdated: (_) {},
              initialRating: review.rating ?? 0,
              ignoreGesture: true,
              ratedColor: Colors.amber,
            ),
            if (review.review?.isEmpty ?? false)
              SizedBox(
                height: 10,
              ),
            if ((review.review?.isNotEmpty) ?? false && showReview)
              Text(
                review.review ?? "no review, inform yadu",
                style: Theme.of(context).textTheme.bodyText1,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
