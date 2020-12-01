import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateTheBookingScreen extends StatefulWidget {
  @override
  _RateTheBookingScreenState createState() => _RateTheBookingScreenState();
}

class _RateTheBookingScreenState extends State<RateTheBookingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [],
          ),
        ),
      ),
    );
  }
}

class RatingTile extends StatelessWidget {
  final String firstSentence, secondSentence;

  const RatingTile({Key key, this.firstSentence, this.secondSentence}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(
        firstSentence,
        style: Theme.of(context).textTheme.bodyText1,
      ),
      Text(
        secondSentence,
        style: Theme.of(context).textTheme.subtitle1,
      ),
      RatingBar.builder(
        allowHalfRating: false,
        itemCount: 5,
        minRating: 1,
        maxRating: 5,
        initialRating: 0,
        itemBuilder: (_, __) {
          return const Icon(Icons.star);
        },
        onRatingUpdate: (r) {},
      )
    ],);
  }
}

class AllBookingsRating{
  final List all = <BookingRating>[];
}

class BookingRating {
  final BookingRatingType type;
  final double stars;
  final String note;
  BookingRating({@required this.type, this.stars=0, this.note=""});

  BookingRating update({BookingRatingType type, double stars,String note}){
    return BookingRating(type: type,note: note,stars: stars);
  }

  toMap(){
    return {
      "type":EnumToString.convertToString(type),
      "type":stars,
      "type":note,
    };
  }

  static fromJson(Map<String,dynamic> j){
    return BookingRating(stars: j["stars"],note:j["note"],type:EnumToString.fromString(BookingRatingType.values, j["type"]));
  }
}

enum BookingRatingType{
  overAll,
  staff,
  fecilities
}
