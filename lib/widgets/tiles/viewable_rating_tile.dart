import 'package:bapp/classes/firebase_structures/rating.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/booking_flow/review.dart';
import 'package:flutter/material.dart';

class ViewableRating extends StatelessWidget {
  final EdgeInsets padding;
  final bool showReview;
  final CompleteBookingRating rating;
  final String name;
  final Function onTap;

  ViewableRating(
      {this.showReview = true,
      this.rating,
      this.onTap,
      this.name,
      this.padding});

  @override
  Widget build(BuildContext context) {
    final overallRating = rating.get(BookingRatingType.overAll);
    if (overallRating == null) {
      Helper.bPrint("no overall rating found");
      return SizedBox();
    }
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(
              height: 10,
            ),
            BappRatingBar(
              initialRating: overallRating.stars,
              ignoreGesture: true,
              ratedColor: Colors.amber,
            ),
            if (rating.review.isNotEmpty)
              SizedBox(
                height: 10,
              ),
            if (rating.review.isNotEmpty && showReview)
              Text(
                rating.review,
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
