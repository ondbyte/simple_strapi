import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:bapp/super_strapi/super_strapi.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BookingX extends X {
  static final i = BookingX._x();
  BookingX._x();

  Future init() async {}

  Future<Booking?> getBookingInCart() async {
    final map = await DefaultDataX.i.getValue(
      DefaultDataKeys.lastBooking,
    );
    if (map is Map<String, dynamic>) {
      final booking = Booking.fromMap(map);
      if (booking is Booking) {
        return booking;
      }
    }
  }

  Future<Booking> addBookingToCart(Booking booking) async {
    await DefaultDataX.i.saveValue(
      DefaultDataKeys.lastBooking,
      booking.toMap(),
    );
    return booking;
  }

  Future<Booking?> clearCart() async {
    final map = await DefaultDataX.i.delete(DefaultDataKeys.lastBooking);
    if (map is Map<String, dynamic>) {
      final booking = Booking.fromMap(map);
      if (booking is Booking) {
        return booking;
      }
    }
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
}
