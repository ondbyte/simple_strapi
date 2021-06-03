import 'package:bapp/helpers/helper.dart';
import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:simple_strapi/simple_strapi.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BookingX extends X {
  static final i = BookingX._x();
  BookingX._x();

  Future init() async {}

  Future<Booking?> getCart({
    Key key = const ValueKey("getCart"),
    required Business? forBusiness,
  }) async {
    final user = UserX.i.user();
    if (user is! User) {
      return null;
    }
    var booking = user.cart;
    if (booking is! Booking) {
      booking = await _createCart();
    }
    if (booking.business?.id != forBusiness?.id) {
      final nulled = booking.copyWIth(
        business: forBusiness,
        products: [],
      );
      booking = await Bookings.update(
        nulled,
      );
    }
    return booking;
  }

  Future<Booking> _createCart() async {
    final user = UserX.i.user();
    if (user is! User) {
      throw BappImpossibleException("No user");
    }
    final cart = await Bookings.create(
      Booking.fresh(
        bookingStatus: BookingStatus.halfWayThrough,
        bookedByUser: user,
      ),
    );
    if (cart is! Booking) {
      throw BappImpossibleException("Unable to create cart");
    }
    final copied = user.copyWIth(cart: cart);
    UserX.i.user(await Users.update(copied));
    return cart;
  }

  Future<Booking?> clearCart() async {
    var booking = UserX.i.user()?.cart;
    if (booking is Booking) {
      booking = booking.setNull(products: true, packages: true, business: true);
      final cleared = await Bookings.update(booking);
      final user = await Users.me(asFindOne: true);
      UserX.i.user(user);
      bPrint("booking");
      print(booking);
      print(cleared);
      return booking;
    }
  }

  Future<Booking?> placeBooking({
    required Booking booking,
    required Business business,
    required User user,
    required Employee employee,
    required Timing timeSlot,
    BookingStatus? status,
  }) async {
    final fromTime = timeSlot.from!;
    final duration =
        booking.products!.fold<int>(0, (pv, e) => pv + e.duration!);
    final endTime = fromTime.add(Duration(minutes: duration));
    booking = booking.copyWIth(
      bookedOn: DateTime.now(),
      business: business,
      bookingStartTime: fromTime,
      bookingEndTime: endTime,
      bookingStatus: status ?? BookingStatus.pendingApproval,
      employee: employee,
    );
    final newBooking = (await Bookings.create(booking));
    if (newBooking is Booking) {
      final newUser =
          user.copyWIth(bookings: [...user.bookings ?? [], newBooking]);
      await Users.update(newUser);
    }
    return newBooking;
  }

  bool isActive(Booking booking) {
    final status = booking.bookingStatus;
    if (status is! BookingStatus) {
      return false;
    }
    return status == BookingStatus.pendingApproval ||
        status == BookingStatus.accepted;
  }

  Future<Booking> cancel(Booking booking, {BookingStatus? status}) async {
    final user = UserX.i.user();
    if (UserX.i.userNotPresent) {
      return booking;
    }

    if (status is! BookingStatus) {
      final role =
          EnumToString.fromString(UserRole.values, user?.role?.name ?? "");
      if (role is UserRole) {
        switch (role) {
          case UserRole.customer:
            {
              status = BookingStatus.cancelledByUser;
              break;
            }
          case UserRole.partner:
            {
              status = BookingStatus.cancelledByOwner;
              break;
            }
          case UserRole.manager:
            {
              status = BookingStatus.cancelledByManager;
              break;
            }
          case UserRole.facilitator:
            {
              status = BookingStatus.cancelledByReceptionist;
              break;
            }
          case UserRole.staff:
            {
              status = BookingStatus.cancelledByStaff;
              break;
            }
          default:
            {
              return booking;
            }
        }
      }
    }
    if (status is! BookingStatus) {
      return booking;
    }
    final updating = booking.copyWIth(bookingStatus: status);
    final updated = await Bookings.update(updating);
    if (updated is Booking) {
      return updated;
    }
    return booking;
  }

  Future<Booking> accept(Booking booking) async {
    if (UserX.i.userNotPresent) {
      return booking;
    }
    final user = UserX.i.user();

    final role =
        EnumToString.fromString(UserRole.values, user?.role?.name ?? "");
    if (role is UserRole && role == UserRole.customer) {
      return booking;
    }
    final updating = booking.copyWIth(bookingStatus: BookingStatus.accepted);
    final updated = await Bookings.update(updating);
    if (updated is Booking) {
      return updated;
    }
    return booking;
  }

  Future<Booking> startJob(Booking booking) async {
    if (UserX.i.userNotPresent) {
      return booking;
    }
    final user = UserX.i.user();

    final role =
        EnumToString.fromString(UserRole.values, user?.role?.name ?? "");
    if (role == UserRole.customer) {
      return booking;
    }
    final updating = booking.copyWIth(bookingStatus: BookingStatus.ongoing);
    final updated = await Bookings.update(updating);
    if (updated is Booking) {
      return updated;
    }
    return booking;
  }

  Future<List<Booking>> getUpcomingBookings(Business business) {
    return Bookings.executeQuery(
      _getUpcomingBookingsOfStatusQuery(
        business,
        [
          BookingStatus.accepted,
          BookingStatus.walkin,
        ],
      )..whereField(
          field: Booking.fields.bookingStartTime,
          query: StrapiFieldQuery.greaterThan,
          value: DateTime.now(),
        ),
    );
  }

  Future<List<Booking>> getUpcomingBookingsToBeAccepted(Business business) {
    return Bookings.executeQuery(
      _getUpcomingBookingsOfStatusQuery(
        business,
        [
          BookingStatus.pendingApproval,
        ],
      )..whereField(
          field: Booking.fields.bookingStartTime,
          query: StrapiFieldQuery.greaterThan,
          value: DateTime.now(),
        ),
    );
  }

  Future<List<Booking>> getAllBookingsForDay(
    Business business,
    DateTime day,
  ) {
    final startEnd = startAndEndOfTheDayOf(day);
    return Bookings.executeQuery(
      _getUpcomingBookingsOfStatusQuery(
        business,
        [
          BookingStatus.accepted,
          BookingStatus.walkin,
        ],
      )
        ..whereField(
          field: Booking.fields.bookingStartTime,
          query: StrapiFieldQuery.greaterThanOrEqualTo,
          value: startEnd.key,
        )
        ..whereField(
          field: Booking.fields.bookingStartTime,
          query: StrapiFieldQuery.lowerThanOrEqualTo,
          value: startEnd.value,
        ),
    );
  }

  StrapiCollectionQuery _businessQuery(Business business) {
    return StrapiCollectionQuery(
      collectionName: Booking.collectionName,
      requiredFields: Booking.fields(),
    );
  }

  StrapiCollectionQuery _getUpcomingBookingsOfStatusQuery(
      Business business, List<BookingStatus> statuses) {
    final q = _businessQuery(business)
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
      ..whereField(
        field: Booking.fields.bookingStatus,
        query: StrapiFieldQuery.includesInAnArray,
        value: [
          ...statuses.map((e) => EnumToString.convertToString(e)).toList()
        ],
      );
    return q;
  }
}
