import 'package:bapp/classes/firebase_structures/business_booking.dart';
import 'package:bapp/classes/firebase_structures/rating.dart';
import 'package:bapp/config/config.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/screens/home/bapp.dart';
import 'package:bapp/screens/misc/contextual_message.dart';
import 'package:bapp/super_strapi/my_strapi/bookingX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/loading_stack.dart';
import 'package:bapp/widgets/tiles/error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_place/google_place.dart' hide Review;
import 'package:super_strapi_generated/super_strapi_generated.dart';

class RateTheBookingScreen extends StatefulWidget {
  final Booking booking;

  const RateTheBookingScreen({Key? key, required this.booking})
      : super(key: key);
  @override
  _RateTheBookingScreenState createState() => _RateTheBookingScreenState();
}

class _RateTheBookingScreenState extends State<RateTheBookingScreen> {
  late Booking _booking;
  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
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
    return Bookings.listenerWidget(
        strapiObject: widget.booking,
        sync: true,
        builder: (context, booking, loading) {
          if (loading) {
            return LoadingWidget();
          }
          var review = booking.review;
          if (review is! Review) {
            return SizedBox();
          }
          _booking = _booking.copyWIth(review: review);
          return WillPopScope(
              onWillPop: () async {
                return true;
              },
              child: LoadingStackWidget(
                  child: Scaffold(
                bottomNavigationBar: BottomPrimaryButton(
                  label: "Send feedback",
                  onPressed: () async {
                    if (review is Review) {
                      BappNavigator.pushAndRemoveAll(
                        context,
                        ContextualMessageScreen(
                          message: "Thank you for your rating",
                          buttonText: "Go to Home",
                          onButtonPressed: (context) {
                            BappNavigator.pushAndRemoveAll(context, Bapp());
                          },
                          init: () async {
                            await Reviews.update(review!);
                          },
                        ),
                      );
                    }
                  },
                ),
                appBar: AppBar(),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        RatingTile(
                          firstSentence: "Review employee",
                          rating: review.emplyeeRating ?? 0,
                          review: review.employeeReview ?? "",
                          onRatingUpdated: (r) {
                            review = review!.copyWIth(emplyeeRating: r);
                            _booking = _booking.copyWIth(review: review);
                          },
                          onReviewUpdated: (s) {
                            review = review!.copyWIth(employeeReview: s);
                            _booking = _booking.copyWIth(review: review);
                          },
                        ),
                        RatingTile(
                          firstSentence: "Review facility",
                          rating: review!.facilityRating ?? 0,
                          review: review!.facilityReview ?? "",
                          onRatingUpdated: (r) {
                            review = review!.copyWIth(facilityRating: r);
                            _booking = _booking.copyWIth(review: review);
                          },
                          onReviewUpdated: (s) {
                            review = review!.copyWIth(facilityReview: s);
                            _booking = _booking.copyWIth(review: review);
                          },
                        ),
                        RatingTile(
                          firstSentence: "Review Overall experience",
                          rating: review!.rating ?? 0,
                          review: review!.review ?? "",
                          onRatingUpdated: (r) {
                            review = review!.copyWIth(rating: r);
                            _booking = _booking.copyWIth(review: review);
                          },
                          onReviewUpdated: (s) {
                            review = review!.copyWIth(review: s);
                            _booking = _booking.copyWIth(review: review);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )));
        });
  }
}

class RatingTile extends StatelessWidget {
  final String? firstSentence, secondSentence;
  final double rating;
  final String review;
  final Function(double) onRatingUpdated;
  final Function(String) onReviewUpdated;

  const RatingTile({
    Key? key,
    this.firstSentence,
    this.secondSentence,
    required this.rating,
    required this.onRatingUpdated,
    required this.review,
    required this.onReviewUpdated,
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
            initialRating: rating,
            onRatingUpdated: (r) {
              onRatingUpdated.call(r);
            },
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            decoration: InputDecoration(labelText: "say something"),
            onChanged: (s) {
              onReviewUpdated.call(s);
            },
          )
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
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final Rx<bool> done = false.obs;

  HowWasYourExperienceTile({
    Key? key,
    this.borderRadius,
    this.padding,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final user = UserX.i.user();
    if (user is! User) {
      return SizedBox();
    }
    return TapToReFetch<List<Booking>>(
        fetcher: () => BookingX.i.getNonReviewedBookingsForUser(user),
        onLoadBuilder: (_) => SizedBox(),
        onErrorBuilder: (_, e, s) {
          bPrint(e);
          bPrint(s);
          return ErrorTile(message: "Something went wrong, tap to retry");
        },
        onSucessBuilder: (context, bookings) {
          if (bookings.isEmpty) {
            return SizedBox();
          }
          final booking = bookings.first;
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
                  Obx(() {
                    return AnimatedSwitcher(
                      duration: const Duration(seconds: 1),
                      child: !done()
                          ? BappRatingBar(
                              onRatingUpdated: (r) async {
                                final newReview = Review.fresh(
                                    rating: r, reviewedOn: DateTime.now());
                                final updated = await Reviews.create(newReview);
                                await Bookings.update(
                                    booking.copyWIth(review: updated!));
                                done(true);
                              },
                              ignoreGesture: done(),
                            )
                          : GestureDetector(
                              onTap: () {
                                BappNavigator.push(
                                  context,
                                  RateTheBookingScreen(
                                    booking: booking,
                                  ),
                                );
                              },
                              child: Text(
                                "Thank you, Click here to fully review your experience",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    );
                  }),
                ],
              ),
            ),
          );
        });
  }
}
