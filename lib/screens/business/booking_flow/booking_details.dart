import 'dart:async';

import 'package:bapp/classes/firebase_structures/bapp_user.dart';
import 'package:bapp/classes/firebase_structures/business_booking.dart';
import 'package:bapp/classes/firebase_structures/business_timings.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/booking_flow/cancellation_confirmation.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/bookingX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/loading_stack.dart';
import 'package:bapp/widgets/padded_text.dart';
import 'package:bapp/widgets/tiles/bapp_user_tile.dart';
import 'package:bapp/widgets/tiles/error.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Booking booking;
  final bool isCustomerView;

  const BookingDetailsScreen({
    Key? key,
    required this.booking,
    this.isCustomerView = true,
  }) : super(key: key);
  @override
  _BookingDetailsScreenState createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final canBeginJob = Rx(false);
  Timer? _timer;
  @override
  void initState() {
    _decideCanBeginJob();
    super.initState();
  }

  void _decideCanBeginJob() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final now = DateTime.now();
      final shouldWaitToStartJob =
          widget.booking.bookingStartTime?.toLocal().isAfter(now) ?? false;
      if (shouldWaitToStartJob) {
        final difference =
            widget.booking.bookingStartTime?.toLocal().difference(now) ??
                Duration.zero;
        Helper.bPrint(difference);
        _timer = Timer(difference, () {
          if (mounted) {
            canBeginJob.value = true;
          }
        });
      } else {
        setState(() {
          canBeginJob.value = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TapToReFetch<Booking>(
      fetcher: () async {
        final booking = await Bookings.findOne(widget.booking.id!);
        return booking!;
      },
      onLoadBuilder: (_) => LoadingWidget(),
      onErrorBuilder: (_, e, s) {
        print(e);
        print(s);
        return ErrorTile(message: "Error occured,Tap to refresh");
      },
      onSucessBuilder: (_, booking) {
        final map = booking.products ?? [];
        final servicesChildren = <Widget>[];
        map.forEach(
          (item) {
            servicesChildren.add(
              PaddedText(
                item.nameOverride ?? "",
                style: Theme.of(context).textTheme.subtitle1,
              ),
            );
            servicesChildren.add(
              PaddedText(
                getProductsDurationString([item]),
                style: Theme.of(context).textTheme.caption,
              ),
            );
          },
        );
        return WillPopScope(
          onWillPop: () async {
            if (_timer != null) {
              _timer?.cancel();
            }
            return true;
          },
          child: Builder(
            builder: (_) {
              return Bookings.listenerWidget(
                strapiObject: widget.booking,
                builder: (_, booking, loading) {
                  if (loading) {
                    return LoadingWidget();
                  }
                  return Scaffold(
                    appBar: AppBar(
                      title: Text("Booking Details"),
                    ),
                    bottomNavigationBar: BookingX.i.isActive(booking)
                        ? widget.isCustomerView
                            ? BottomPrimaryButton(
                                label: "Cancel booking",
                                onPressed: isCancellableBooking(booking)
                                    ? () async {
                                        final confirm = await BappNavigator
                                            .dialog<CancellationConfirm>(
                                          context,
                                          CancellationConfirmDialog(
                                            title: "Cancel",
                                            message: "Please specify a reason",
                                            needReason: true,
                                          ),
                                        );
                                        if (confirm is! CancellationConfirm) {
                                          return;
                                        }
                                        if (!confirm.confirm) {
                                          return;
                                        }
                                        await BookingX.i.cancel(booking,
                                            status:
                                                BookingStatus.cancelledByUser);
                                        BappNavigator.pop(context, null);
                                      }
                                    : null,
                              )
                            : booking.bookingStatus ==
                                    BookingStatus.pendingApproval
                                ? AcceptOrRejectButton(
                                    confirmLabel: "Confirm Booking",
                                    rejectLabel: "Reject",
                                    onConfirm: () async {
                                      await BookingX.i.accept(booking);
                                      BappNavigator.pop(context, null);
                                    },
                                    onReject: () async {
                                      final confirm = await BappNavigator
                                          .dialog<CancellationConfirm>(
                                        context,
                                        CancellationConfirmDialog(
                                          title: "Reject",
                                          message: "Please specify a reason",
                                        ),
                                      );
                                      if (confirm is! CancellationConfirm) {
                                        return;
                                      }
                                      if (!confirm.confirm) {
                                        return;
                                      }
                                      await BookingX.i.cancel(booking);
                                      BappNavigator.pop(context, null);
                                    },
                                  )
                                : booking.bookingStatus ==
                                        BookingStatus.accepted
                                    ? Obx(() => StartJobOrNoShowButton(
                                          noShowLabel: "No Show",
                                          startJobLabel: "Start Job",
                                          onNoShow: () async {
                                            final confirm = await BappNavigator
                                                .dialog<CancellationConfirm>(
                                              context,
                                              CancellationConfirmDialog(
                                                title: "No show",
                                                message:
                                                    "Mark this as no show?",
                                              ),
                                            );
                                            if (confirm
                                                is! CancellationConfirm) {
                                              return;
                                            }
                                            if (!confirm.confirm) {
                                              return;
                                            }
                                            act(() {
                                              kLoading.value = true;
                                            });
                                            await BookingX.i.cancel(booking,
                                                status: BookingStatus.noShow);
                                            BappNavigator.pop(context, null);
                                          },
                                          onStart: canBeginJob()
                                              ? () async {
                                                  await BookingX.i.startJob(
                                                    booking,
                                                  );
                                                  BappNavigator.pop(
                                                      context, null);
                                                }
                                              : null,
                                        ))
                                    : null
                        : null,
                    body: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.all(16),
                      children: [
                        TitledListTile(
                          bottomTag: readableEnum(booking.bookingStatus),
                          bottomTagColor:
                              getColorForBooking(booking.bookingStatus),
                          primaryTile: widget.isCustomerView
                              ? ListTile(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 16),
                                  title: Text(
                                    booking.business?.name ??
                                        "no business name inform yadu",
                                    style:
                                        Theme.of(context).textTheme.headline1,
                                  ),
                                  subtitle: Text(
                                    booking.business?.address?.locality?.name ??
                                        "no locality inform yadu",
                                  ),
                                )
                              : null,
                          title: widget.isCustomerView ? null : "Customer",
                          secondaryTile: widget.isCustomerView
                              ? ListTile(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 16),
                                  leading: ListTileFirebaseImage(
                                    ifEmpty: Initial(
                                      forName: booking.employee?.name ?? "zz",
                                    ),
                                    storagePathOrURL:
                                        booking.employee?.image?.first.url,
                                  ),
                                  title: Text(
                                    "Your booking is with",
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                  subtitle: Text(booking.employee!.name!),
                                )
                              : BappUserTile(
                                  user: booking.bookedByUser!,
                                ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Builder(
                          builder: (_) {
                            final from = booking.bookingStartTime;
                            final to = booking.bookingEndTime;
                            if (from is! DateTime && to is! DateTime) {
                              return SizedBox();
                            }
                            return TitledListTile(
                              title: "Schedule",
                              caption: getOnForTime(booking.bookingStartTime!) +
                                  ", " +
                                  getProductsDurationString(booking.products!),
                            );
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TitledListTile(
                          title: "Services",
                          secondaryTile: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: servicesChildren,
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class TitledListTile extends StatelessWidget {
  final String? title, secondaryTitle, caption;
  final EdgeInsets? contentPadding;
  final BorderRadius? borderRadius;
  final Widget? primaryTile, secondaryTile;
  final String? bottomTag;
  final Color? bottomTagColor;

  const TitledListTile(
      {Key? key,
      this.title,
      this.secondaryTitle,
      this.caption,
      this.contentPadding,
      this.borderRadius,
      this.secondaryTile,
      this.bottomTag,
      this.primaryTile,
      this.bottomTagColor = Colors.grey})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    assert(!(secondaryTitle != null && secondaryTile != null) ||
        ((secondaryTile != null && caption != null)));
    assert(!(primaryTile != null && title != null));
    return Container(
      padding: contentPadding ?? EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(6),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (primaryTile != null) primaryTile as Widget,
          if (title != null)
            PaddedText(
              title as String,
              style: Theme.of(context).textTheme.headline6,
            ),
          if (title != null) SizedBox(height: 20),
          if (secondaryTitle != null)
            PaddedText(
              secondaryTitle as String,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          if (caption != null)
            PaddedText(
              caption as String,
              style: Theme.of(context).textTheme.caption,
            ),
          if (secondaryTile != null) secondaryTile as Widget,
          if (bottomTag != null)
            Divider(
              color: Theme.of(context).dividerColor,
            ),
          if (bottomTag != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: bottomTagColor),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  if (bottomTag is String)
                    Text(
                      bottomTag as String,
                      style: TextStyle(color: bottomTagColor),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class StartJobOrNoShowButton extends StatelessWidget {
  final Function()? onStart, onNoShow;
  final String startJobLabel, noShowLabel;
  final Color? backGroundColor;
  final EdgeInsets? padding;

  const StartJobOrNoShowButton({
    Key? key,
    this.onStart,
    this.onNoShow,
    required this.startJobLabel,
    required this.noShowLabel,
    this.backGroundColor,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(16),
      color: backGroundColor ?? Theme.of(context).backgroundColor,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: FlatButton(
              color: Theme.of(context).primaryColor,
              textTheme: ButtonTextTheme.primary,
              onPressed: onStart,
              child: Text(startJobLabel),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: FlatButton(
              color: Theme.of(context).errorColor,
              textTheme: ButtonTextTheme.primary,
              onPressed: onNoShow,
              child: Text(noShowLabel),
            ),
          )
        ],
      ),
    );
  }
}

class AcceptOrRejectButton extends StatelessWidget {
  final Function()? onConfirm, onReject;
  final String confirmLabel, rejectLabel;
  final Color? backGroundColor;
  final EdgeInsets? padding;

  const AcceptOrRejectButton(
      {Key? key,
      this.onConfirm,
      this.onReject,
      required this.confirmLabel,
      required this.rejectLabel,
      this.backGroundColor,
      this.padding})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(16),
      color: backGroundColor ?? Theme.of(context).backgroundColor,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: FlatButton(
              color: Theme.of(context).primaryColor,
              textTheme: ButtonTextTheme.primary,
              onPressed: onConfirm,
              child: Text(confirmLabel),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: FlatButton(
              color: Theme.of(context).errorColor,
              textTheme: ButtonTextTheme.primary,
              onPressed: onReject,
              child: Text(rejectLabel),
            ),
          )
        ],
      ),
    );
  }
}
