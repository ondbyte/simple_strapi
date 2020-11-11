import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/firebase_structures/business_services.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BusinessServicesTab extends StatefulWidget {

  const BusinessServicesTab({Key key,}) : super(key: key);
  @override
  _BusinessServicesTabState createState() => _BusinessServicesTabState();
}

class _BusinessServicesTabState extends State<BusinessServicesTab> {

  BookingFlow get flow => Provider.of<BookingFlow>(context,listen: false);

  @override
  Widget build(BuildContext context) {
    final sorted = <BusinessServiceCategory,List<BusinessService>>{};
    final services = flow.branch.businessServices.value;
    services.allCategories.forEach((cat) {
      final all = services.all.where((serv) => serv.category.value.categoryName==cat.categoryName);
      sorted.addAll({cat:all});
    });
    return ListView.builder(itemBuilder: (_,i){
      return BusinessCategoryContainerWidget(
        category: sorted.keys.elementAt(i),
        services: sorted.values.elementAt(i),
      );
    });
  }
}

class BusinessCategoryContainerWidget extends StatefulWidget {
  final BusinessServiceCategory category;
  final List<BusinessService> services;

  const BusinessCategoryContainerWidget({Key key, this.category, this.services})
      : super(key: key);
  @override
  _BusinessCategoryContainerWidgetState createState() =>
      _BusinessCategoryContainerWidgetState();
}

class _BusinessCategoryContainerWidgetState
    extends State<BusinessCategoryContainerWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          EnumToString.convertToString(widget.category.categoryName.value),
          style: Theme.of(context).textTheme.headline1,
        ),
        const SizedBox(
          height: 20,
        ),
        ..._getServicesTiles(),
      ],
    );
  }

  BookingFlow get flow => Provider.of<BookingFlow>(context,listen: false);

  List<Widget> _getServicesTiles() {
    bool _booked(BusinessService s) {
      return flow.services
          .any((element) => element.serviceName == s.serviceName);
    }

    final list = <Widget>[];
    widget.services.forEach((s) {
      list.add(BusinessServiceChildWidget(
        service: s,
        bookWidget: _booked(s) ? bookButton(s) : cancelBookingButton(s),
      ));
    });
    return list;
  }

  Widget bookButton(BusinessService s) {
    return FlatButton(
      onPressed: () {
        flow.services.add(s);
      },
      child: const Text("Book"),
    );
  }

  Widget cancelBookingButton(BusinessService s) {
    return FlatButton(
      onPressed: () {
        flow.services
            .removeWhere((element) => element.serviceName == s.serviceName);
      },
      child: const Text("Cancel"),
    );
  }
}

class BusinessServiceChildWidget extends StatelessWidget {
  final BusinessService service;
  final Widget bookWidget;

  const BusinessServiceChildWidget({Key key, this.service, this.bookWidget})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(service.serviceName.value),
      subtitle: _makeSubTitle(context),
      trailing: bookWidget,
    );
  }

  Widget _makeSubTitle(BuildContext context) {
    final flow = Provider.of<BookingFlow>(context,listen: false);
    final s = service.price.value.toString() +
        " " +
        flow.branch.misc.currency +
        ", " +
        service.duration.value.inMinutes.toString() +
        " Minutes" +
        "\n" +
        service.description.value;
    return Text(
      s,
      maxLines: 2,
    );
  }
}
