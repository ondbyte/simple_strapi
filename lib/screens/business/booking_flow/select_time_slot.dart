import 'package:bapp/helpers/exceptions.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/super_strapi/my_strapi/businessX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';

import 'package:bapp/widgets/bapp_calendar.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/tiles/error.dart';
import 'package:bapp/widgets/tiles/rr_list_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';
import 'package:table_calendar/table_calendar.dart';

class SelectTimeSlotScreen extends StatefulWidget {
  final Business business;
  final Employee employee;
  final Duration durationOfServices;

  const SelectTimeSlotScreen(
      {Key? key,
      required this.business,
      required this.employee,
      required this.durationOfServices})
      : super(key: key);
  @override
  _SelectTimeSlotScreenState createState() => _SelectTimeSlotScreenState();
}

class _SelectTimeSlotScreenState extends State<SelectTimeSlotScreen> {
  final _controller = CalendarController();

  DateTime? _selectedDay;
  final _selected = Rx<Timing?>(null);

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
                onPressed: (_selected() is! Timing)
                    ? null
                    : () async {
                        BappNavigator.pop(context, _selected() as Timing);
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
                        getAvailableSlotsKey = ValueKey(
                          DateTime.now(),
                        );
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
            body: Builder(
              builder: (_) {
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
    if (now.hour <= 11 && now.minute <= 59) {
      return 0;
    }
    if (now.hour < 15 && now.minute <= 59) {
      return 1;
    }
    return 2;
  }

  var getAvailableSlotsKey = ValueKey(DateTime.now());
  Widget _getTimeSlotTabs() {
    return TapToReFetch<List<Timing>>(
      fetcher: () => BusinessX.i.getAvailableSlots(
          widget.business, widget.employee, _selectedDay ?? DateTime.now(),
          key: getAvailableSlotsKey,
          durationOfServices: widget.durationOfServices),
      onTap: () => getAvailableSlotsKey = ValueKey(DateTime.now()),
      onLoadBuilder: (_) => LoadingWidget(),
      onErrorBuilder: (_, e, s) {
        if (e is EmployeeHolidayException) {
          return ErrorTile(message: "The selected employee is on holiday");
        }
        if (e is BusinessHolidayException) {
          return ErrorTile(
              message: "The Business is durationon holiday for the day");
        }
        if (e is EmployeeNotBookableException) {
          return ErrorTile(
              message:
                  "Selected staff is not bookable,toggle in employee settings");
        }
        return ErrorTile(message: "Something went wrong, tap to refresh");
      },
      onSucessBuilder: (_, timingsList) {
        final timings = <Timing>[];

        timingsList.forEach((e) {
          timings.addAll(divideTimingIntoChunksOfDuration(e));
        });
        final sorted = sortTimingsForPeriodOfTheDay(timings);
        return TabBarView(
          children: [
            Obx(() {
              return TimeSlotsWidget(
                key: UniqueKey(),
                fromToTimings: sorted["morning"]!,
                selected: _selected(),
                onATimeSlotSelected: (timeSlot) {
                  _selected.value = timeSlot;
                },
              );
            }),
            Obx(() {
              return TimeSlotsWidget(
                key: UniqueKey(),
                fromToTimings: sorted["afterNoon"]!,
                selected: _selected(),
                onATimeSlotSelected: (timeSlot) {
                  _selected.value = timeSlot;
                },
              );
            }),
            Obx(() {
              return TimeSlotsWidget(
                key: UniqueKey(),
                fromToTimings: sorted["evening"]!,
                selected: _selected(),
                onATimeSlotSelected: (timeSlot) {
                  _selected.value = timeSlot;
                },
              );
            }),
          ],
        );
      },
    );
  }
}

class TimeSlotsWidget extends StatefulWidget {
  final Function(Timing?) onATimeSlotSelected;
  final Timing? selected;
  final List<Timing> fromToTimings;

  const TimeSlotsWidget({
    Key? key,
    required this.fromToTimings,
    required this.onATimeSlotSelected,
    required this.selected,
  }) : super(key: key);
  @override
  _TimeSlotsWidgetState createState() => _TimeSlotsWidgetState();
}

class _TimeSlotsWidgetState extends State<TimeSlotsWidget> {
  Timing? selectedTiming;
  @override
  void initState() {
    super.initState();
    selectedTiming = widget.selected;
  }

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
            selected: widget.fromToTimings[i].from == selectedTiming?.from,
            onClicked: (b) {
              setState(() {
                selectedTiming = b ? widget.fromToTimings[i] : null;
                widget.onATimeSlotSelected(selectedTiming);
              });
            },
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
  Widget build(BuildContext context) {
    return RRShape(
      child: Builder(
        builder: (_) {
          return GestureDetector(
            onTap: () {
              widget.onClicked?.call(!widget.selected);
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: widget.selected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.all(Radius.circular(4))),
              margin: EdgeInsets.all(8),
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyText1?.apply(
                        color: widget.selected ? Colors.white : Colors.black) ??
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
