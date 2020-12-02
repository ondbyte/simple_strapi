import 'package:bapp/classes/firebase_structures/business_booking.dart';
import 'package:bapp/classes/firebase_structures/rating.dart';
import 'package:bapp/config/config.dart';
import 'package:bapp/helpers/extensions.dart';

import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/screens/home/bapp.dart';
import 'package:bapp/screens/misc/contextual_message.dart';
import 'package:bapp/widgets/loading_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateTheBookingScreen extends StatefulWidget {
  final BusinessBooking booking;

  const RateTheBookingScreen({Key key, this.booking}) : super(key: key);
  @override
  _RateTheBookingScreenState createState() => _RateTheBookingScreenState();
}

class _RateTheBookingScreenState extends State<RateTheBookingScreen> {
  @override
  Widget build(BuildContext context) {
    return LoadingStackWidget(
      child: Scaffold(
        bottomNavigationBar: BottomPrimaryButton(
          label: "Send feedback",
          onPressed: widget.booking.rating.isEdited()
              ? () async {
                  BappNavigator.bappPushAndRemoveAll(
                    context,
                    ContextualMessageScreen(
                      message: RatingConfig.getThankYouForTheReviewForBooking(widget.booking),
                      buttonText: "Go to Home",
                      onButtonPressed: (context){
                        BappNavigator.bappPushAndRemoveAll(context, Bapp());
                      },
                      init: () async {
                        await widget.booking.saveRating();
                      },
                    ),
                  );
                  Navigator.pop(context);
                }
              : null,
        ),
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              shrinkWrap: true,
              children: [
                ...List.generate(
                  widget.booking.rating.all.length,
                  (i) {
                    final r = widget.booking.rating.all.values.elementAt(i);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: RatingTile(
                        firstSentence:
                            RatingConfig.getFirstSentenceForRating(r),
                        secondSentence:
                            RatingConfig.getSecondSentenceForRatingWithBooking(
                                    r, widget.booking) +
                                "?",
                        rating: r,
                        onRatingUpdated: (newR) {
                          widget.booking.rating.update(newR);
                          setState(() {});
                        },
                      ),
                    );
                  },
                ),
                TextFormField(
                  initialValue: widget.booking.rating.review,
                  onChanged: (s) {
                    widget.booking.rating.review = s;
                  },
                  decoration: const InputDecoration(
                    labelText: RatingConfig.reviewLabel,
                    hintText: RatingConfig.reviewHint,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RatingTile extends StatelessWidget {
  final String firstSentence, secondSentence;
  final BookingRating rating;
  final Function(BookingRating) onRatingUpdated;

  const RatingTile(
      {Key key,
      this.firstSentence,
      this.secondSentence,
      this.rating,
      this.onRatingUpdated})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            firstSentence,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          Text(
            secondSentence,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          const SizedBox(
            height: 20,
          ),
          BappRatingBar(
            initialRating: rating.stars,
            unratedColor: Theme.of(context).indicatorColor,
            onRatingUpdated: (r) {
              onRatingUpdated(rating.update(stars: r));
            },
          ),
        ],
      ),
    );
  }
}

class BappRatingBar extends StatelessWidget {
  final Function(double) onRatingUpdated;
  final bool ignoreGesture;
  final Color unratedColor, ratedColor;
  final double initialRating;

  const BappRatingBar(
      {Key key,
      this.onRatingUpdated,
      this.ignoreGesture,
      this.unratedColor = Colors.white,
      this.ratedColor = Colors.amber,
      this.initialRating = 0})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return RatingBar(
      initialRating: initialRating,
      unratedColor: unratedColor ?? Colors.white,
      ratingWidget: RatingWidget(
        empty: Icon(
          Icons.star_border_outlined,
          color: unratedColor,
        ),
        half: Icon(
          Icons.star_half_outlined,
          color: ratedColor,
        ),
        full: Icon(
          Icons.star_outlined,
          color: ratedColor,
        ),
      ),
      onRatingUpdate: onRatingUpdated,
    );

  }
}

class HowWasYourExperienceTile extends StatelessWidget {
  final BusinessBooking booking;
  final BorderRadius borderRadius;
  final EdgeInsets padding;

  const HowWasYourExperienceTile(
      {Key key, this.booking, this.borderRadius, this.padding})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(6),
      child: ListTile(
        onTap: () {
          BappNavigator.bappPush(
            context,
            RateTheBookingScreen(
              booking: booking,
            ),
          );
        },
        tileColor: CardsColor.colors["lightGreen"],
        contentPadding: padding ?? const EdgeInsets.all(16),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "How was your experience at",
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .apply(color: Colors.white),
            ),
            Text(
              "How was your experience at",
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .apply(color: Colors.white),
            ),
            BappRatingBar(
              onRatingUpdated: (_) {},
              ignoreGesture: true,
            )
          ],
        ),
      ),
    );
  }
}
