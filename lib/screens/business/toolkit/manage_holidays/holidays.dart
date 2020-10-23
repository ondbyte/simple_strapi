import 'package:bapp/config/config.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/firebase_structures/business_holidays.dart';
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
          color: Theme.of(context).primaryColorLight,
        ),
        onPressed: () {
          Navigator.of(context)
              .pushNamed(RouteManager.businessAddAHolidayScreen);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Manage your holidays"),
      ),
      body: Consumer<BusinessStore>(
        builder: (_, businessStore, __) {
          final holidays = businessStore.business.businessHolidays.value;
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
                                child: Icon(Icons.delete,color: Theme.of(context).primaryColorLight,),
                              ),
                              onDismissed: (_){
                                holidays.removeHoliday(holidays.all[index]);
                              },
                              child: HolidayWidget(
                                holiday: holidays.all[index],
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

  const HolidayWidget({Key key, this.holiday}) : super(key: key);

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
            onChanged: (b) {
              act(
                () {
                  widget.holiday.enabled.value = b;
                },
              );
            },
          ),
        );
      },
    );
  }
}
