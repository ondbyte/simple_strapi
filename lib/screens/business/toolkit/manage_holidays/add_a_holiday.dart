import 'package:bapp/config/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

class BusinessAddAHolidayScreen extends StatefulWidget {
  @override
  _BusinessAddAHolidayScreenState createState() =>
      _BusinessAddAHolidayScreenState();
}

class _BusinessAddAHolidayScreenState extends State<BusinessAddAHolidayScreen> {
  List<DateTime> _pickedDates = [];
  String _type = "";
  String _details = "";
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Add Holiday"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          child: Column(
            children: [
              ButtonTheme(
                buttonColor: Colors.teal,
                child: GestureDetector(
                  onTap: () async {
                    final _pickedDates = await DateRagePicker.showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2040),
                      initialFirstDate: DateTime.now(),
                      initialLastDate: DateTime.now().add(
                        Duration(days: 1),
                      ),
                    );
                    if (_pickedDates == null) {
                      return;
                    }
                    final f = DateFormat("dd");
                    final f2 = DateFormat("dd MMMM, yyyy");
                    _controller.text = f.format(_pickedDates[0]) +
                        " to " +
                        f2.format(_pickedDates[1]);
                  },
                  child: TextFormField(
                    enabled: false,
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: "Select Dates",
                      suffixIcon: Icon(
                        Icons.calendar_today_outlined,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: "Holiday Type"),
                items: <DropdownMenuItem>[
                  ...List.generate(
                    kHolidayTypes.length,
                    (index) => DropdownMenuItem(
                      value: kHolidayTypes[index],
                      child: Text(
                        kHolidayTypes[index],
                      ),
                    ),
                  ),
                ],
                onChanged: (v) {},
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                maxLength: 60,
                maxLengthEnforced: true,
                maxLines: 2,
                decoration: InputDecoration(labelText: "Enter Details"),
                onChanged: (s) {
                  _details = s;
                },
                validator: (s) {
                  if (s.length < 5) {
                    return "Enter valid detail";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
