import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/firebase_structures/business_timings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:mobx/mobx.dart';

class BusinessTimingsScreen extends StatefulWidget {
  @override
  _BusinessTimingsScreenState createState() => _BusinessTimingsScreenState();
}

class _BusinessTimingsScreenState extends State<BusinessTimingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Manage working hours"),
      ),
      body: Consumer<BusinessStore>(
        builder: (_, businessStore, __) {
          return Observer(
            builder: (_) {
              final timings = businessStore
                  .business.businessTimings.value.allDayTimings.value;
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          ...List.generate(
                            timings.length,
                            (index) => DayTimingsWidget(
                              dayName: timings[index].dayName,
                              dayTiming: timings[index],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class DayTimingsWidget extends StatefulWidget {
  final String dayName;
  final DayTiming dayTiming;

  const DayTimingsWidget({Key key, this.dayName, this.dayTiming})
      : super(key: key);
  @override
  _DayTimingsWidgetState createState() => _DayTimingsWidgetState();
}

class _DayTimingsWidgetState extends State<DayTimingsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      color: Theme.of(context).cardColor,
      child: Observer(
        builder: (_) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.dayName,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Switch(
                      activeColor: Theme.of(context).primaryColor,
                      activeTrackColor: Theme.of(context).primaryColor,
                      value: widget.dayTiming.enabled.value,
                      onChanged: (b) {
                        act(() {
                          widget.dayTiming.enabled.value = b;
                        });
                      })
                ],
              ),
              if (widget.dayTiming.timings.value.isNotEmpty)
                Observer(builder: (_) {
                  return IgnorePointer(
                    ignoring: !widget.dayTiming.enabled.value,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.dayTiming.timings.value.length,
                      itemBuilder: (_, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: DayTimingRowWidget(
                            fromToTiming: widget.dayTiming.timings.value[index],
                            onRemove: () {
                              act(() {
                                widget.dayTiming.timings.value.removeAt(index);
                              });
                            },
                            onChange: (cd) {
                              act(() {
                                widget.dayTiming.timings.value[index] = cd;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  );
                }),
              Observer(
                builder: (_) {
                  return IgnorePointer(
                    ignoring: !widget.dayTiming.enabled.value,
                    child: IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: () {
                        act(() {
                          final old = widget.dayTiming.timings.value;
                          final neww = ObservableList<FromToTiming>();
                          neww.addAll([
                            ...old,
                            FromToTiming(
                              from: DateTime(0, 0, 0, 9),
                              to: DateTime(0, 0, 0, 18),
                            )
                          ]);
                          widget.dayTiming.timings.value = neww;
                          print(neww.toString());
                        });
                      },
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class DayTimingRowWidget extends StatefulWidget {
  final FromToTiming fromToTiming;
  final Function onRemove;
  final Function(FromToTiming) onChange;

  const DayTimingRowWidget(
      {Key key, this.fromToTiming, this.onRemove, this.onChange})
      : super(key: key);

  @override
  _DayTimingRowWidgetState createState() => _DayTimingRowWidgetState();
}

class _DayTimingRowWidgetState extends State<DayTimingRowWidget> {
  FromToTiming _fromToTiming;
  @override
  void initState() {
    _fromToTiming = widget.fromToTiming;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 8,
            ),
            Text(
              format(_fromToTiming.from),
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text("To"),
            Text(
              format(_fromToTiming.to),
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(
              width: 8,
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                await _edit();
              },
            ),
            IconButton(
              icon: Icon(Icons.remove_circle_outline),
              onPressed: widget.onRemove,
            ),
          ],
        );
      },
    );
  }

  _edit() async {
    final TimeRange timeRange = await showTimeRangePicker(
      context: context,
      backgroundColor: Theme.of(context).primaryColor,
      interval: const Duration(minutes: 15),
      start: TimeOfDay.fromDateTime(_fromToTiming.from),
      end: TimeOfDay.fromDateTime(_fromToTiming.to),
      handlerRadius: 32,
      snap: true,
      use24HourFormat: false,
    );
    if(timeRange==null){
      return;
    }
    final from =
        DateTime(0, 0, 0, timeRange.startTime.hour, timeRange.startTime.minute);
    final to =
        DateTime(0, 0, 0, timeRange.endTime.hour, timeRange.endTime.minute);
    setState(
      () {
        _fromToTiming = FromToTiming(from: from, to: to);
        widget.onChange(_fromToTiming);
      },
    );
  }

  String format(DateTime dt) {
    return DateFormat.jm().format(dt);
  }
}
