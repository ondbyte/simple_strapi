import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';

class CompleteBookingRating {
  final all = <BookingRatingType, BookingRating>{
    BookingRatingType.overAll: BookingRating(type: BookingRatingType.overAll),
    BookingRatingType.staff: BookingRating(type: BookingRatingType.staff),
    BookingRatingType.fecilities:
        BookingRating(type: BookingRatingType.fecilities)
  };
  String review;
  final bool isRated;

  CompleteBookingRating({this.review = "", this.isRated = false});

  bool isEdited() {
    double i = 0;
    all.forEach((key, value) {
      i += value.stars;
    });
    return i != 0;
  }

  BookingRating update(BookingRating rating) {
    all[rating.type] = rating;
  }

  BookingRating get(BookingRatingType type) {
    return all[type];
  }

  static fromJson(Map<String, dynamic> j) {
    final _new = CompleteBookingRating(
        review: j.remove("review"), isRated: j.remove("isRated"));
    j.forEach((key, value) {
      _new.update(BookingRating.fromJson(value));
    });
    return _new;
  }

  Map<String, dynamic> toMap() {
    final tmp = all.map((key, value) =>
        MapEntry(EnumToString.convertToString(key), value.toMap()));
    return {...tmp, "review": review, "isRated": isRated};
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

enum BookingRatingType { overAll, staff, fecilities }
