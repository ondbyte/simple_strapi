/* import 'package:bapp/helpers/helper.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';

enum BookingRatingPhase {
  notRated,
  overallRated,
  fullyRated,
}

class CompleteBookingRating {
  final all = <BookingRatingType, BookingRating>{
    BookingRatingType.overAll: BookingRating(type: BookingRatingType.overAll),
    BookingRatingType.staff: BookingRating(type: BookingRatingType.staff),
    BookingRatingType.facilities:
        BookingRating(type: BookingRatingType.facilities)
  };
  String review;
  final  bookingRatingPhase = Observable<BookingRatingPhase>(null);

  CompleteBookingRating(
      {this.review = "",BookingRatingPhase bookingRatingPhase = BookingRatingPhase.notRated}){
    this.bookingRatingPhase.value = bookingRatingPhase;
  }

  void updatePhase(BookingRatingPhase phase){
    act((){
      bookingRatingPhase.value = phase;
    });
  }

  bool isEdited() {
    var i = 0.0;
    all.forEach((key, value) {
      i += value.stars;
    });
    return i != 0;
  }

  void update(BookingRating rating) {
    all[rating.type] = rating;
  }

  BookingRating get(BookingRatingType type) {
    return all[type];
  }

  static CompleteBookingRating fromJson(Map<String, dynamic> j) {
    final _new = CompleteBookingRating(
        review: j.remove("review"),
        bookingRatingPhase: EnumToString.fromString(
            BookingRatingPhase.values, j.remove("bookingRatingPhase")));
    j.forEach((key, value) {
      _new.update(BookingRating.fromJson(value));
    });
    return _new;
  }

  Map<String, dynamic> toMap() {
    final tmp = all.map((key, value) =>
        MapEntry(EnumToString.convertToString(key), value.toMap()));
    return {
      ...tmp,
      "review": review,
      "bookingRatingPhase": EnumToString.convertToString(bookingRatingPhase.value),
    };
  }
}

class BookingRating {
  final BookingRatingType type;
  final double stars;
  final String note;
  BookingRating({@required this.type, this.stars = 0, this.note = ""});

  BookingRating update({BookingRatingType type, double stars, String note}) {
    return BookingRating(
        type: type ?? this.type,
        note: note ?? this.note,
        stars: stars ?? this.stars);
  }

  toMap() {
    return {
      "type": EnumToString.convertToString(type),
      "stars": stars,
      "note": note,
    };
  }

  static fromJson(Map<String, dynamic> j) {
    return BookingRating(
        stars: j["stars"],
        note: j["note"],
        type: EnumToString.fromString(BookingRatingType.values, j["type"]));
  }
}

enum BookingRatingType { overAll, staff, facilities }
 */