
import 'package:bapp/stores/business_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BusinessManageHolidaysScreen extends StatefulWidget {
  @override
  _BusinessManageHolidaysScreenState createState() => _BusinessManageHolidaysScreenState();
}

class _BusinessManageHolidaysScreenState extends State<BusinessManageHolidaysScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Manage your holidays"),
      ),
      body: Consumer<BusinessStore>(
        builder: (_,businessStore,__){
          final holidays = businessStore.business.businessHolidays.value;
          return CustomScrollView(
            slivers: [
              SliverPadding(padding: EdgeInsets.all(16),sliver: SliverList(
                delegate: SliverChildListDelegate([
                  ...List.generate(holidays.all.value.length, (index) => HolidayWidget(holiday:holidays.all.value.entries.elementAt(index),),),
                ],),
              ),)
            ],
          );
        },
      ),
    );
  }
}

class HolidayWidget extends StatefulWidget {
  final MapEntry holiday;

  const HolidayWidget({Key key, this.holiday}) : super(key: key);

  _HolidayWidgetState createState() => _HolidayWidgetState();
}

class _HolidayWidgetState extends State<HolidayWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

