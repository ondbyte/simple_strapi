import 'package:bapp/classes/firebase_structures/business_holidays.dart';
import 'package:bapp/config/config.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/business/toolkit/manage_holidays/add_a_holiday.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BusinessManageHolidaysScreen extends StatefulWidget {
  @override
  _BusinessManageHolidaysScreenState createState() =>
      _BusinessManageHolidaysScreenState();
}

class _BusinessManageHolidaysScreenState
    extends State<BusinessManageHolidaysScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Theme.of(context).indicatorColor,
        ),
        onPressed: () {
          BappNavigator.push(context, BusinessAddAHolidayScreen());
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Manage your holidays"),
      ),
      body: Consumer<BusinessStore>(
        builder: (_, businessStore, __) {
          final holidays = businessStore
              .business.selectedBranch.value.businessHolidays.value;
          return Observer(
            builder: (_) {
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          ...List.generate(
                            holidays.all.length,
                            (index) => Dismissible(
                              key: GlobalKey(),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: CardsColor.colors["teal"],
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Icon(
                                  Icons.delete,
                                  color: Theme.of(context).indicatorColor,
                                ),
                              ),
                              onDismissed: (_) {
                                holidays.removeHoliday(holidays.all[index]);
                              },
                              child: HolidayWidget(
                                holiday: holidays.all[index],
                                onSwitch: (b) {
                                  act(
                                    () {
                                      holidays.all[index].enabled.value = b;
                                      holidays.save();
                                    },
                                  );
                                },
                              ),
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

class HolidayWidget extends StatefulWidget {
  final BusinesssHoliday holiday;
  final Function(bool) onSwitch;

  const HolidayWidget({Key key, this.holiday, this.onSwitch}) : super(key: key);

  _HolidayWidgetState createState() => _HolidayWidgetState();
}

class _HolidayWidgetState extends State<HolidayWidget> {
  final f = DateFormat("dd");
  final f2 = DateFormat("dd MMMM, yyyy");
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return ListTile(
          title: Text(widget.holiday.name),
          subtitle: Text(
            f.format(widget.holiday.dates.first) +
                " to " +
                f2.format(widget.holiday.dates.last),
          ),
          trailing: Switch(
            value: widget.holiday.enabled.value,
            onChanged: widget.onSwitch,
          ),
        );
      },
    );
  }
}
