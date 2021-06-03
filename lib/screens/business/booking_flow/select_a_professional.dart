import 'package:bapp/helpers/exceptions.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business/booking_flow/select_time_slot.dart';
import 'package:bapp/super_strapi/my_strapi/businessX.dart';
import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/tiles/employee_tile.dart';
import 'package:bapp/widgets/tiles/error.dart';
import 'package:bapp/widgets/tiles/rr_list_tile.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class SelectAProfessionalScreen extends StatefulWidget {
  final String? title;
  final String? subTitle;
  final Business business;
  final DateTime forDay;
  const SelectAProfessionalScreen({
    Key? key,
    required this.business,
    required this.forDay,
    this.title,
    this.subTitle,
  }) : super(key: key);
  @override
  _SelectAProfessionalScreenState createState() =>
      _SelectAProfessionalScreenState();
}

class _SelectAProfessionalScreenState extends State<SelectAProfessionalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select A Professional"),
        automaticallyImplyLeading: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (true)
                  RRShape(
                    child: widget.title is String
                        ? ListTile(
                            tileColor: Theme.of(context).backgroundColor,
                            title: Text(widget.title!),
                            subtitle: widget.subTitle is String
                                ? Text(widget.subTitle!)
                                : null,
                          )
                        : null,
                  ),
                const SizedBox(
                  height: 20,
                ),
                _getProffessionalsTiles()
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getProffessionalsTiles() {
    return TapToReFetch<Map<String, List<Employee>>?>(
        fetcher: () => BusinessX.i.availableEmployees(
              widget.business,
              widget.forDay,
            ),
        onLoadBuilder: (_) => LoadingWidget(),
        onErrorBuilder: (_, e, s) {
          bPrint(e);
          bPrint(s);
          if (e is BusinessHolidayException) {
            return ErrorTile(message: "The business is holiday today");
          }
          return ErrorTile(message: "$e");
        },
        onSucessBuilder: (_, employeesMap) {
          if (employeesMap is! Map) {
            return ErrorTile(message: "No employees available");
          }
          final availableEmplyeesWidget = <Widget>[];
          final unAvailableEmplyeesWidget = <Widget>[];

          final availableEmplyees = employeesMap?["availableEmployees"] ?? [];
          final unAvailableEmplyees =
              employeesMap?["unAvailableEmployees"] ?? [];
          if (availableEmplyees is List) {
            if (availableEmplyees.isEmpty) {
              availableEmplyeesWidget.add(Text("No proffesional available"));
            }
            availableEmplyeesWidget.addAll(
              List.generate(
                availableEmplyees.length,
                (index) => EmployeeTile(
                  employee: availableEmplyees[index],
                  enabled: true,
                  onTap: () {
                    BappNavigator.pop(
                      context,
                      availableEmplyees[index],
                    );
                  },
                ),
              ),
            );
          }
          if (unAvailableEmplyees is List) {
            unAvailableEmplyeesWidget.addAll(
              List.generate(
                unAvailableEmplyees.length,
                (index) => EmployeeTile(
                  employee: unAvailableEmplyees[index],
                  enabled: false,
                ),
              ),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...availableEmplyeesWidget,
              ...unAvailableEmplyeesWidget,
            ],
          );
        });
  }
}
