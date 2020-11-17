import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/firebase_structures/business_timings.dart';
import 'package:bapp/widgets/bapp_calendar.dart';
import 'package:bapp/widgets/tiles/rr_list_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class SelectTimeSlotScreen extends StatefulWidget {
  @override
  _SelectTimeSlotScreenState createState() => _SelectTimeSlotScreenState();
}

class _SelectTimeSlotScreenState extends State<SelectTimeSlotScreen> {
  var _holiday = Observable(false);
  var _controller = CalendarController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Timeslot"),
      ),
      bottomNavigationBar: Observer(builder: (_) {
        return BottomPrimaryButton(
          label: "Confirm booking",
          onPressed: flow.slot.value == null ? null : () {},
        );
      }),
      body: DefaultTabController(
        length: 3,
        initialIndex: 1,
        child: NestedScrollView(
          headerSliverBuilder: (_, __) {
            return [
              SliverAppBar(
                collapsedHeight: 180,
                expandedHeight: 180,
                pinned: true,
                automaticallyImplyLeading: false,
                flexibleSpace: BappRowCalender(
                  controller: _controller,
                  holidays: flow.holidays,
                  initialDate: flow.timeWindow.value.from,
                  onDayChanged: (day, _, holidays) {
                    if (holidays.isNotEmpty) {
                      act(() {
                        _holiday.value = true;
                      });
                    } else {
                      act(
                        () {
                          _holiday.value = false;
                        },
                      );
                    }
                    act(() {
                      flow.timeWindow.value = FromToTiming.forDay(day);
                    });
                  },
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    getBappTabBar(context, [
                      Text("Morning"),
                      Text("Afternoon"),
                      Text("Evening"),
                    ]),
                  ],
                ),
              )
            ];
          },
          body: _getTimeSlotTabs(),
        ),
      ),
    );
  }

  Widget _getTimeSlotTabs() {
    return TabBarView(children: [
      TimeSlotsWidget(
        fromToTimings: flow.professional.value.morningTimings,
      ),
      TimeSlotsWidget(
        fromToTimings: flow.professional.value.afterNoonTimings,
      ),
      TimeSlotsWidget(
        fromToTimings: flow.professional.value.eveTimings,
      ),
    ]);
  }

  BookingFlow get flow => Provider.of<BookingFlow>(context, listen: false);
}

class TimeSlotsWidget extends StatefulWidget {
  final ObservableList<FromToTiming> fromToTimings;

  const TimeSlotsWidget({Key key, @required this.fromToTimings})
      : super(key: key);
  @override
  _TimeSlotsWidgetState createState() => _TimeSlotsWidgetState();
}

class _TimeSlotsWidgetState extends State<TimeSlotsWidget> {
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      if (widget.fromToTimings.isEmpty) {
        return Text("No timings");
      }
      return Padding(
        padding: EdgeInsets.all(16),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 16 / 6),
          itemCount: widget.fromToTimings.length,
          itemBuilder: (_, i) {
            return TimeSlot(
              label: widget.fromToTimings[i].from.toTimeOfDay(),
              onClicked: (b) {
                act(() {
                  flow.slot.value = b ? widget.fromToTimings[i].from : null;
                });
              },
            );
          },
        ),
      );
    });
  }

  BookingFlow get flow => Provider.of<BookingFlow>(context, listen: false);
}

class TimeSlot extends StatefulWidget {
  final TimeOfDay label;
  final Function(bool) onClicked;

  const TimeSlot({Key key, this.label, this.onClicked}) : super(key: key);
  @override
  _TimeSlotState createState() => _TimeSlotState();
}

class _TimeSlotState extends State<TimeSlot> {
  final format = DateFormat("hh:mm a");
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  BookingFlow get flow => Provider.of(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return RRShape(
      child: Observer(
        builder: (_) {
          final _selected = flow.slot.value == null
              ? false
              : widget.label.isSame(flow.slot.value.toTimeOfDay());
          return GestureDetector(
            onTap: () {
              widget.onClicked(!_selected);
            },
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(8),
              child: DefaultTextStyle(
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .apply(color: _selected ? Colors.white : Colors.black),
                child: Text(format.format(widget.label.toDateAndTime())),
              ),
              color: _selected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).backgroundColor,
            ),
          );
        },
      ),
    );
  }
}
