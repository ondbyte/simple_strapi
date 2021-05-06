import 'dart:io';

import 'package:bapp/fcm.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/screens/home/bapp.dart';
import 'package:bapp/screens/misc/contextual_message.dart';
import 'package:bapp/super_strapi/my_strapi/bookingX.dart';
import 'package:bapp/super_strapi/my_strapi/businessX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';

import 'package:bapp/widgets/bapp_calendar.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/tiles/error.dart';
import 'package:bapp/widgets/tiles/rr_list_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:simple_strapi/simple_strapi.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';
import 'package:table_calendar/table_calendar.dart';

class SelectTimeSlotScreen extends StatefulWidget {
  final Business business;
  final Employee employee;

  const SelectTimeSlotScreen(
      {Key? key, required this.business, required this.employee})
      : super(key: key);
  @override
  _SelectTimeSlotScreenState createState() => _SelectTimeSlotScreenState();
}

class _SelectTimeSlotScreenState extends State<SelectTimeSlotScreen> {
  var _holiday = Observable(false);
  var _controller = CalendarController();

  DateTime? _selectedDay;
  Timing? _selected;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Select Timeslot"),
        ),
        bottomNavigationBar: Obx(
          () {
            final user = UserX.i.user();
            if (UserX.i.userNotPresent) {
              return SizedBox();
            }
            return BottomPrimaryButton(
                label: "Confirm booking",
                onPressed: (_selected is! DayTiming)
                    ? null
                    : () async {
                        BappNavigator.pop(context, _selected as Timing);
                      }
                /* () async {
                      await BappNavigator.pushAndRemoveAll(
                        context,
                        ContextualMessageScreen(
                          svgAssetToDisplay: "assets/svg/success.svg",
                          message:
                              "Your booking has been placed, please show up minutes before the booking",
                          buttonText:
                              Platform.isIOS && !BappFCM().isFcmInitialized
                                  ? "Enable reminder for this booking"
                                  : "Back to home",
                          init: () async {
                            await flow.done();
                          },
                          onButtonPressed: (context) async {
                            if (Platform.isIOS && !BappFCM().isFcmInitialized) {
                              await BappFCM().requestOnIOS();
                            } else {
                              BappNavigator.pushAndRemoveAll(
                                context,
                                Bapp(),
                              );
                            }
                          },
                          secondarybuttonText:
                              Platform.isIOS && !BappFCM().isFcmInitialized
                                  ? "Back to home"
                                  : null,
                          secondaryButtonPressed: (context) {
                            BappNavigator.pushAndRemoveAll(
                              context,
                              Bapp(),
                            );
                          },
                        ),
                      );
                    } */
                );
          },
        ),
        body: DefaultTabController(
          length: 3,
          initialIndex: _getInitialIndexForPeriodOfTheDay(),
          child: NestedScrollView(
            headerSliverBuilder: (_, __) {
              return [
                SliverAppBar(
                  elevation: 0,
                  collapsedHeight: 150,
                  expandedHeight: 150,
                  pinned: true,
                  automaticallyImplyLeading: false,
                  flexibleSpace: BappRowCalender(
                    controller: _controller,
                    holidays:
                        BusinessX.i.getHolidaysOfBusiness(widget.business),
                    initialDate: _selectedDay ?? DateTime.now(),
                    onDayChanged: (day, _, holidays) {
                      setState(() {
                        _selectedDay = day;
                      });
                    },
                  ),
                ),
                SliverAppBar(
                  elevation: 0,
                  pinned: true,
                  automaticallyImplyLeading: false,
                  flexibleSpace: getBappTabBar(context, [
                    const Text("Morning"),
                    const Text("Afternoon"),
                    const Text("Evening"),
                  ]),
                )
              ];
            },
            body: Observer(
              builder: (_) {
                if (_holiday.value) {
                  return const Text("Its holiday");
                }
                return _getTimeSlotTabs();
              },
            ),
          ),
        ),
      );
    });
  }

  int _getInitialIndexForPeriodOfTheDay() {
    final now = DateTime.now().toTimeOfDay();
    if (now.isAM()) {
      return 0;
    }
    if (now.hour < 3 && now.minute <= 59) {
      return 1;
    }
    return 2;
  }

  Widget _getTimeSlotTabs() {
    return TapToReFetch<List<Timing>>(
      fetcher: () => BusinessX.i.getAvailableSlots(
        widget.business,
        widget.employee,
        _selectedDay ?? DateTime.now(),
      ),
      onLoadBuilder: (_) => LoadingWidget(),
      onErrorBuilder: (_, e, s) => ErrorTile(message: "$e"),
      onSucessBuilder: (_, timingsList) {
        final timings = <Timing>[];
        timingsList?.forEach((e) {
          timings.addAll(divideTimingIntoChunksOfDuration(e));
        });
        final sorted = sortTimingsForPeriodOfTheDay(timings);
        return TabBarView(
          children: [
            TimeSlotsWidget(
              key: UniqueKey(),
              fromToTimings: sorted["morning"]!,
            ),
            TimeSlotsWidget(
              key: UniqueKey(),
              fromToTimings: sorted["afterNoon"]!,
            ),
            TimeSlotsWidget(
              key: UniqueKey(),
              fromToTimings: sorted["evening"]!,
            ),
          ],
        );
      },
    );
  }
}

class TimeSlotsWidget extends StatefulWidget {
  final List<Timing> fromToTimings;

  const TimeSlotsWidget({Key? key, required this.fromToTimings})
      : super(key: key);
  @override
  _TimeSlotsWidgetState createState() => _TimeSlotsWidgetState();
}

class _TimeSlotsWidgetState extends State<TimeSlotsWidget> {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (_) {
      if (widget.fromToTimings.isEmpty) {
        return const Center(
          child: Text("No timings"),
        );
      }
      return GridView.builder(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 16 / 6),
        itemCount: widget.fromToTimings.length,
        itemBuilder: (_, i) {
          final label = widget.fromToTimings[i].from?.toTimeOfDay();
          if (label is! TimeOfDay) {
            return SizedBox();
          }
          return TimeSlot(
            label: label,
            onClicked: (b) {},
          );
        },
      );
    });
  }
}

class TimeSlot extends StatefulWidget {
  final TimeOfDay label;
  final Function(bool)? onClicked;
  final bool selected;

  const TimeSlot(
      {Key? key, required this.label, this.onClicked, this.selected = false})
      : super(key: key);
  @override
  _TimeSlotState createState() => _TimeSlotState();
}

class _TimeSlotState extends State<TimeSlot> {
  final format = DateFormat("hh:mm a");
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return RRShape(
      child: Observer(
        builder: (_) {
          final _selected = widget.selected;
          return GestureDetector(
            onTap: () {
              widget.onClicked?.call(!_selected);
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: _selected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.all(Radius.circular(4))),
              margin: EdgeInsets.all(8),
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyText1?.apply(
                        color: _selected ? Colors.white : Colors.black) ??
                    TextStyle(),
                child: Text(format.format(widget.label.toDateAndTime())),
              ),
            ),
          );
        },
      ),
    );
  }
}
