import 'package:bapp/classes/firebase_structures/staff_time_off.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/booking_flow/add_customer_details.dart';
import 'package:bapp/screens/business/booking_flow/select_a_professional.dart';
import 'package:bapp/screens/business/booking_flow/select_time_slot.dart';
import 'package:bapp/screens/business/booking_flow/services_screen.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/screens/business/toolkit/manage_staff/manage_staff.dart';
import 'package:bapp/screens/misc/contextual_message.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/super_strapi/my_strapi/bookingX.dart';
import 'package:bapp/super_strapi/my_strapi/persistenceX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';
import 'package:bapp/widgets/bapp_calendar.dart';
import 'package:bapp/widgets/booking_timeline.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/tiles/employee_tile.dart';
import 'package:bapp/widgets/tiles/error.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';
import 'package:table_calendar/table_calendar.dart';

class BusinessBookingsTab extends StatefulWidget {
  final Function() keepAlive;

  const BusinessBookingsTab({Key? key, required this.keepAlive})
      : super(key: key);
  @override
  _BusinessBookingsTabState createState() => _BusinessBookingsTabState();
}

class _BusinessBookingsTabState extends State<BusinessBookingsTab>
    with AutomaticKeepAliveClientMixin {
  final _calendarController = CalendarController();
  final _selectedDay = Rx(DateTime.now());
  final _pickedEmployee = Rx<Employee?>(null);

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final user = UserX.i.user();
    _pickedEmployee.value = user?.pickedEmployee;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = UserX.i.user();
    if (user is! User) {
      return Text("no user");
    }
    final partner = user.partner;
    if (partner is! Partner) {
      return Text("No partner");
    }

    var pickedBusiness = user.pickedBusiness;
    if (pickedBusiness is! Business) {
      return Text("No business selected");
    }
    return Businesses.listenerWidget(
        strapiObject: pickedBusiness,
        sync: true,
        builder: (context, business, loading) {
          return Scaffold(
            floatingActionButton: Obx(
              () {
                return _pickedEmployee() is! Employee
                    ? SizedBox()
                    : FloatingActionButton(
                        onPressed: () {
                          Get.dialog(
                            BookingsTabAddOptions(
                              business: business,
                              selectedEmployee: _pickedEmployee()!,
                            ),
                          );
                        },
                        child: Icon(FeatherIcons.plus),
                      );
              },
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            body: Builder(builder: (_) {
              final employeeSelector = () async {
                final e = await Get.to(
                  SelectAProfessionalScreen(
                    forDay: DateTime.now(),
                    business: business,
                  ),
                );
                if (e is Employee) {
                  _pickedEmployee.value = e;
                  final user = UserX.i.user();
                  if (user is User) {
                    final copied = user.copyWIth(pickedEmployee: e);
                    final updated = await Users.update(copied);
                    UserX.i.user(updated);
                  }
                }
              };
              return TapToReFetch<List<Booking>>(
                  fetcher: () => BookingX.i
                      .getAllBookingsForDay(business, _selectedDay.value),
                  onLoadBuilder: (_) => LoadingWidget(),
                  onErrorBuilder: (_, e, s) => ErrorTile(message: e.toString()),
                  onSucessBuilder: (context, list) {
                    return CustomScrollView(
                      slivers: [
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Obx(() {
                                if (_pickedEmployee() is Employee) {
                                  return EmployeeTile(
                                    employee: _pickedEmployee()!,
                                    enabled: true,
                                    onTap: employeeSelector,
                                  );
                                } else {
                                  return ListTile(
                                    onTap: employeeSelector,
                                    title: Text("Staff"),
                                    subtitle: Text("Select a staff"),
                                    trailing: Icon(FeatherIcons.arrowRight),
                                  );
                                }
                              }),
                              BappRowCalender(
                                bookings: bookingsAsCalendarEvents(list),
                                initialDate: DateTime.now(),
                                holidays: holidaysAsCalendarEvents(
                                    business.holidays ?? []),
                                controller: _calendarController,
                                onDayChanged: (day, _, __) {
                                  _selectedDay.value = day;
                                },
                              ),
                            ],
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              SizedBox(
                                height: 0,
                              ),
                              Obx(
                                () {
                                  return _pickedEmployee() is! Employee
                                      ? Align(
                                          alignment: Alignment.center,
                                          child: Text("Select a employee"),
                                        )
                                      : Obx(() => BookingTimeLineWidget(
                                            timing: _beginingOfTheDay(
                                                _selectedDay.value,
                                                business.dayTiming ?? []),
                                            date: _selectedDay.value,
                                            list: list
                                                .where((e) =>
                                                    e.bookingStartTime?.isDay(
                                                        _selectedDay.value) ??
                                                    false)
                                                .toList(),
                                          ));
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  });
            }),
          );
        });
  }

  Timing? _beginingOfTheDay(DateTime day, List<DayTiming> dayTimings) {
    if (dayTimings.isEmpty) {
      return null;
    }
    final dayName = DateFormatters.dayName.format(day).toLowerCase();
    try {
      final timing = dayTimings.firstWhere(
        (element) => EnumToString.convertToString(element.dayName) == dayName,
      );
      final f = timing.timings?.first.from;
      final t = timing.timings?.last.to;
      if (f is DateTime && t is DateTime) {
        return Timing(enabled: false, from: f.toLocal(), to: t.toLocal());
      }
    } catch (e, s) {
      bPrint(
        e,
      );
      bPrint(s);
    }
  }

  @override
  bool get wantKeepAlive => widget.keepAlive();
}

class BookingsTabAddOptions extends StatefulWidget {
  final Employee selectedEmployee;
  final Business business;

  const BookingsTabAddOptions(
      {Key? key, required this.business, required this.selectedEmployee})
      : super(key: key);
  @override
  _BookingsTabAddOptionsState createState() => _BookingsTabAddOptionsState();
}

class _BookingsTabAddOptionsState extends State<BookingsTabAddOptions> {
  final _loading = Rx<bool>(false);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Obx(() {
        if (_loading.value) {
          return LoadingWidget();
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("Add Walk-In"),
              trailing: Icon(Icons.arrow_forward),
              onTap: () async {
                final products = await Get.to(
                  BusinessProfileServicesScreen(
                    business: widget.business,
                  ),
                );
                if (products is List && products.isNotEmpty) {
                  final ps = products as List<Product>;
                  final timeSlot = await Get.to(SelectTimeSlotScreen(
                      business: widget.business,
                      employee: widget.selectedEmployee,
                      durationOfServices: Duration(
                          minutes: ps.fold(
                              0, (previousValue, e) => e.duration ?? 0))));
                  if (timeSlot is Timing) {
                    final user = await Get.to(
                      AddCustomerDetails(),
                    );
                    if (user is User) {
                      _loading.value = true;
                      final booking = Booking.fresh(products: products);
                      await BookingX.i.placeBooking(
                        booking: booking,
                        business: widget.business,
                        user: user,
                        employee: widget.selectedEmployee,
                        timeSlot: timeSlot,
                        status: BookingStatus.walkin,
                      );
                      await Businesses.findOne(widget.business.id!);
                      _loading.value = false;
                      Flushbar(
                        message: "Walkin added successfully",
                      ).show(context);
                    }
                  }
                }
              },
            ),
            ListTile(
              title: Text("Add Booking"),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {},
            ),
            ListTile(
              title: Text("Block time"),
              trailing: Icon(Icons.arrow_forward),
              enabled: false,
              onTap: null,
            ),
            ListTile(
              title: Text("Time off"),
              trailing: Icon(Icons.arrow_forward),
              enabled: false,
              onTap: null,
            ),
          ],
        );
      }),
    );
  }
}

class BlockTimeScreen extends StatefulWidget {
  @override
  _BlockTimeScreenState createState() => _BlockTimeScreenState();
}

class _BlockTimeScreenState extends State<BlockTimeScreen> {
  final _calendarCtrl = CalendarController();
  var _saving = false;

  @override
  void dispose() {
    _calendarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox();
    /* return Consumer<BookingFlow>(
      builder: (_, flow, __) {
        final _staffTimeOff = StaffTimeOff(
          myDoc: StaffTimeOff.newRef(),
          staff: flow.professional.value.staff,
          type: StaffTimeOffType.partial,
        );

        _staffTimeOff.from = DateTime.now();
        _staffTimeOff.to = DateTime.now().add(const Duration(hours: 1));

        return Scaffold(
          bottomNavigationBar: BottomPrimaryButton(
            label: "Update",
            onPressed: _saving
                ? null
                : () async {
                    if (_staffTimeOff.to.difference(_staffTimeOff.from) >
                        Duration(minutes: 15)) {
                      if (_staffTimeOff.reason.isNotEmpty) {
                        setState(() {
                          _saving = true;
                        });
                        await _staffTimeOff.save();
                        BappNavigator.pop(context, null);
                      } else {
                        Flushbar(
                          message: "Reason should not be empty",
                          duration: const Duration(seconds: 4),
                        ).show(context);
                        _saving = false;
                      }
                    } else {
                      setState(() {
                        _saving = false;
                      });
                      Flushbar(
                        message: "Block time must be atleast 15 minutes",
                        duration: const Duration(seconds: 4),
                      ).show(context);
                    }
                  },
          ),
          appBar: AppBar(
            centerTitle: true,
            title: Text("Block time"),
          ),
          body: NestedScrollView(
            headerSliverBuilder: (_, __) {
              return [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      BappRowCalender(
                        controller: _calendarCtrl,
                        initialDate: DateTime.now(),
                        holidays: flow.branch.businessHolidays.value
                            .holidaysForBappCalender(),
                        onDayChanged: (day, __, ___) {
                          _staffTimeOff.from = _staffTimeOff.from.toDay(day);
                          _staffTimeOff.to = _staffTimeOff.to.toDay(day);
                        },
                      )
                    ],
                  ),
                ),
              ];
            },
            body: ListView(
              shrinkWrap: true,
              children: [
                BusinessStaffListTile(
                  staff: flow.professional.value.staff,
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: FromToDatePicker(
                    onChange: (from, to) {
                      _staffTimeOff.from = from.toDay(_staffTimeOff.from);
                      _staffTimeOff.to = to.toDay(_staffTimeOff.to);
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    onChanged: (s) {
                      _staffTimeOff.reason = s;
                    },
                    maxLines: 5,
                    decoration: InputDecoration(labelText: "Reason"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
   */
  }
}

class FromToDatePicker extends StatefulWidget {
  final bool onlyTime;
  final DateTime from, to;
  final Function(DateTime, DateTime)? onChange;

  const FromToDatePicker(
      {Key? key,
      this.onlyTime = true,
      required this.from,
      required this.to,
      this.onChange})
      : super(key: key);
  @override
  _FromToDatePickerState createState() => _FromToDatePickerState();
}

class _FromToDatePickerState extends State<FromToDatePicker> {
  var fromTime = DateTime.now();
  var toTime = DateTime.now().add(const Duration(hours: 1));
  final timeFormatter = DateFormat.jm();
  final dateFormatter = DateFormat.yMd();

  final fromCtrl = TextEditingController();
  final toCtrl = TextEditingController();

  @override
  void initState() {
    fromTime = widget.from;
    toTime = widget.to;
    fromCtrl.text = timeFormatter.format(fromTime);
    toCtrl.text = timeFormatter.format(toTime);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "From",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              TextFormField(
                readOnly: true,
                controller: fromCtrl,
                onTap: () async {
                  final tod = await showTimePicker(
                      context: context, initialTime: fromTime.toTimeOfDay());
                  if (tod != null) {
                    fromTime = tod.toDateAndTime();
                    fromCtrl.text = timeFormatter.format(fromTime);
                    widget.onChange?.call(fromTime, toTime);
                  }
                },
              ),
            ],
          ),
        ),
        SizedBox(
          width: 20,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "To",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              TextFormField(
                readOnly: true,
                controller: toCtrl,
                onTap: () async {
                  final tod = await showTimePicker(
                      context: context, initialTime: toTime.toTimeOfDay());
                  if (tod != null) {
                    toTime = tod.toDateAndTime();
                    if (toTime
                            .toTimeOfDay()
                            .compareTo(fromTime.toTimeOfDay()) ==
                        -1) {
                      toTime = fromTime.add(Duration(minutes: 1));
                    }
                    toCtrl.text = timeFormatter.format(toTime);
                    widget.onChange?.call(fromTime, toTime);
                  }
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}
