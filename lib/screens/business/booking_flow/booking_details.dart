import 'package:bapp/classes/firebase_structures/bapp_user.dart';
import 'package:bapp/classes/firebase_structures/business_booking.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:bapp/widgets/loading_stack.dart';
import 'package:bapp/widgets/padded_text.dart';
import 'package:bapp/widgets/tiles/bapp_user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class BookingDetailsScreen extends StatefulWidget {
  final BusinessBooking booking;
  final bool isCustomerView;

  const BookingDetailsScreen(
      {Key key, this.booking, this.isCustomerView = true})
      : super(key: key);
  @override
  _BookingDetailsScreenState createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final map = widget.booking.getServiceNamesWithDuration();
    final servicesChildren = <Widget>[];
    map.forEach((key, value) {
      servicesChildren.add(PaddedText(
        key,
        style: Theme.of(context).textTheme.subtitle1,
      ));
      servicesChildren.add(PaddedText(
        value,
        style: Theme.of(context).textTheme.caption,
      ));
    });
    return LoadingStackWidget(
      child: Consumer<CloudStore>(
        builder: (_, cloudStore, __) {
          return Observer(
            builder: (_) {
              return Scaffold(
                appBar: AppBar(
                  title: Text("Booking Details"),
                ),
                bottomNavigationBar: widget.booking.isActive()
                    ? widget.isCustomerView
                        ? BottomPrimaryButton(
                            label: "Cancel booking",
                            onPressed: () async {
                              act(() {
                                kLoading.value = true;
                              });
                              await widget.booking.cancel(
                                  withStatus:
                                      cloudStore.getCancelTypeForUserType());
                              act(() {
                                kLoading.value = false;
                              });
                              BappNavigator.pop(context, null);
                            },
                          )
                        : widget.booking.status.value ==
                                BusinessBookingStatus.pending
                            ? ConfirmOrRejectButton(
                                confirmLabel: "Confirm Booking",
                                rejectLabel: "Reject",
                                onConfirm: () async {
                                  act(() {
                                    kLoading.value = true;
                                  });
                                  await widget.booking.accept();
                                  act(() {
                                    kLoading.value = false;
                                  });
                                  BappNavigator.pop(context, null);
                                },
                                onReject: () async {
                                  act(() {
                                    kLoading.value = true;
                                  });
                                  await widget.booking.cancel(
                                      withStatus: cloudStore
                                          .getCancelTypeForUserType());
                                  act(() {
                                    kLoading.value = false;
                                  });
                                  BappNavigator.pop(context, null);
                                },
                              )
                            : SizedBox()
                    : null,
                body: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(16),
                  children: [
                    TitledListTile(
                      bottomTag: BusinessBooking.getButtonLabel(
                          widget.booking.status.value),
                      bottomTagColor:
                          BusinessBooking.getColor(widget.booking.status.value),
                      primaryTile: widget.isCustomerView
                          ? ListTile(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16),
                              title: Text(
                                widget.booking.branch.name.value,
                                style: Theme.of(context).textTheme.headline1,
                              ),
                              subtitle: Text(widget.booking.branch.locality),
                            )
                          : null,
                      title: widget.isCustomerView ? null : "Customer",
                      secondaryTile: widget.isCustomerView
                          ? ListTile(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16),
                              leading: ListTileFirebaseImage(
                                ifEmpty: Initial(forName: widget.booking.staff.name,),
                                storagePathOrURL:
                                    widget.booking.staff.images.isNotEmpty
                                        ? widget.booking.staff.images.keys
                                            .elementAt(0)
                                        : null,
                              ),
                              title: Text(
                                "Your booking is with",
                                style: Theme.of(context).textTheme.caption,
                              ),
                              subtitle: Text(
                                widget.booking.staff.name,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            )
                          : FutureBuilder<BappUser>(
                              future: cloudStore.getUserForNumber(
                                  number: widget.booking.bookedByNumber),
                              builder: (_, snap) {
                                if (snap.hasData) {
                                  return BappUserTile(
                                    user: snap.data,
                                  );
                                }
                                return BappUserTile();
                              },
                            ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TitledListTile(
                      title: "Schedule",
                      secondaryTitle:
                          widget.booking.fromToTiming.formatFromWithDate(),
                      caption: widget.booking.fromToTiming.format() +
                          ", " +
                          widget.booking.fromToTiming.formatMinutes(),
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
  }
}

class TitledListTile extends StatelessWidget {
  final String title, secondaryTitle, caption;
  final EdgeInsets contentPadding;
  final BorderRadius borderRadius;
  final Widget primaryTile, secondaryTile;
  final String bottomTag;
  final Color bottomTagColor;

  const TitledListTile(
      {Key key,
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
          if (primaryTile != null) primaryTile,
          if (title != null)
            PaddedText(
              title,
              style: Theme.of(context).textTheme.headline2,
            ),
          if (title != null) SizedBox(height: 20),
          if (secondaryTitle != null)
            PaddedText(
              secondaryTitle,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          if (caption != null)
            PaddedText(
              caption,
              style: Theme.of(context).textTheme.caption,
            ),
          if (secondaryTile != null) secondaryTile,
          if (bottomTag != null)
            Divider(
              color: Theme.of(context).indicatorColor,
              thickness: .5,
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
                  Text(
                    bottomTag,
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

class ConfirmOrRejectButton extends StatelessWidget {
  final Function onConfirm, onReject;
  final String confirmLabel, rejectLabel;
  final Color backGroundColor;
  final EdgeInsets padding;

  const ConfirmOrRejectButton(
      {Key key,
      this.onConfirm,
      this.onReject,
      this.confirmLabel,
      this.rejectLabel,
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
