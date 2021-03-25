import 'package:bapp/classes/firebase_structures/business_booking.dart';
import 'package:bapp/classes/firebase_structures/rating.dart';
import 'package:bapp/config/config.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/screens/home/bapp.dart';
import 'package:bapp/screens/misc/contextual_message.dart';
import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:bapp/widgets/loading_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_place/google_place.dart' hide Review;
import 'package:super_strapi_generated/super_strapi_generated.dart';

class RateTheBookingScreen extends StatefulWidget {
  final Review booking;

  const RateTheBookingScreen({Key? key, required this.booking})
      : super(key: key);
  @override
  _RateTheBookingScreenState createState() => _RateTheBookingScreenState();
}

class _RateTheBookingScreenState extends State<RateTheBookingScreen> {
  Booking? booking;
  @override
  void initState() {
    super.initState();
    /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      act(() {
        kLoading.value = true;
      });

      */ /*widget.booking.myDoc.snapshots().listen((snap) async {
        if(mounted){
          setState(() {
            booking = BusinessBooking.fromSnapShot(
                snap: snap, branch: widget.booking.branch);
            act(() {
              kLoading.value = false;
            });
          });
        }
      });*/ /*
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox();
    /* if (booking == null) {
      return SizedBox();
    }
    return WillPopScope(
        onWillPop: () async {
          widget.booking.rating.updatePhase(BookingRatingPhase.overallRated);
          widget.booking.saveRating();
          return true;
        },
        child: LoadingStackWidget(
          child: Scaffold(
            bottomNavigationBar: BottomPrimaryButton(
              label: "Send feedback",
              onPressed: booking.rating.isEdited()
                  ? () async {
                      BappNavigator.pushAndRemoveAll(
                        context,
                        ContextualMessageScreen(
                          message:
                              RatingConfig.getThankYouForTheReviewForBooking(
                                  booking),
                          buttonText: "Go to Home",
                          onButtonPressed: (context) {
                            BappNavigator.pushAndRemoveAll(context, Bapp());
                          },
                          init: () async {
                            booking.rating
                                .updatePhase(BookingRatingPhase.fullyRated);
                            await booking.saveRating();
                          },
                        ),
                      );
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
                      booking.rating.all.length,
                      (i) {
                        final r = booking.rating.all.values.elementAt(i);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: RatingTile(
                            firstSentence:
                                RatingConfig.getFirstSentenceForRating(r),
                            secondSentence: RatingConfig
                                    .getSecondSentenceForRatingWithBooking(
                                        r, booking) +
                                "?",
                            rating: r,
                            onRatingUpdated: (newR) {
                              booking.rating.update(newR);
                              setState(() {});
                            },
                          ),
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: booking.rating.review,
                      onChanged: (s) {
                        booking.rating.review = s;
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
        ));
   */
  }
}

class RatingTile extends StatelessWidget {
  final String? firstSentence, secondSentence;
  final Review rating;
  final Function(Review)? onRatingUpdated;

  const RatingTile({
    Key? key,
    this.firstSentence,
    this.secondSentence,
    required this.rating,
    this.onRatingUpdated,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (firstSentence is String)
            Text(
              firstSentence as String,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          if (secondSentence is String)
            Text(
              secondSentence as String,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          const SizedBox(
            height: 20,
          ),
          BappRatingBar(
            ignoreGesture: false,
            initialRating: rating.rating ?? 0,
            unratedColor: Theme.of(context).indicatorColor,
            onRatingUpdated: (r) {
              onRatingUpdated?.call(rating.copyWIth(rating: r));
            },
          ),
        ],
      ),
    );
  }
}

class BappRatingBar extends StatelessWidget {
  final void Function(double) onRatingUpdated;
  final bool ignoreGesture;
  final Color unratedColor, ratedColor;
  final double initialRating;

  const BappRatingBar(
      {Key? key,
      required this.onRatingUpdated,
      required this.ignoreGesture,
      this.unratedColor = Colors.amber,
      this.ratedColor = Colors.amber,
      this.initialRating = 0})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return RatingBar(
      initialRating: initialRating,
      unratedColor: unratedColor,
      updateOnDrag: false,
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
  final Booking booking;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  const HowWasYourExperienceTile(
      {Key? key, required this.booking, this.borderRadius, this.padding})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(6),
      child: ListTile(
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
                  ?.apply(color: Colors.white),
            ),
            Text(
              booking.business?.name ?? "no business name inform yadu",
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.apply(color: Colors.white),
            ),
            BappRatingBar(
              onRatingUpdated: (r) {
                final newReview = booking.review?.copyWIth(rating: r);
                if (newReview is Review) {
                  Reviews.update(newReview);
                  BappNavigator.push(
                    context,
                    RateTheBookingScreen(
                      booking: newReview,
                    ),
                  );
                }
              },
              ignoreGesture: false,
            )
          ],
        ),
      ),
    );
  }
}
