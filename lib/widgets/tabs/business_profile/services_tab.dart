import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/firebase_structures/business_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BusinessProfileServicesTab extends StatefulWidget {
  const BusinessProfileServicesTab({
    Key key,
  }) : super(key: key);
  @override
  _BusinessProfileServicesTabState createState() =>
      _BusinessProfileServicesTabState();
}

class _BusinessProfileServicesTabState
    extends State<BusinessProfileServicesTab> {
  BookingFlow get flow => Provider.of<BookingFlow>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    final sorted = <BusinessServiceCategory, List<BusinessService>>{};
    final services = flow.branch.businessServices.value.all;
    final categories = flow.branch.businessServices.value.allCategories;
    categories.forEach((cat) {
      final all = services.where((serv) =>
          serv.category.value.categoryName.value == cat.categoryName.value);
      if (all.isNotEmpty) {
        sorted.addAll({cat: all.toList()});
      }
    });
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(sorted.length, (i) {
          return BusinessCategoryContainerWidget(
            category: sorted.keys.elementAt(i),
            services: sorted.values.elementAt(i),
          );
        })
      ],
    );
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
      shrinkWrap: true,
      children: [
        Text(
          widget.category.categoryName.value,
          style: Theme.of(context).textTheme.headline1,
        ),
        const SizedBox(
          height: 20,
        ),
        ..._getServicesTiles(),
      ],
    );
  }

  BookingFlow get flow => Provider.of<BookingFlow>(context, listen: false);

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
    final flow = Provider.of<BookingFlow>(context, listen: false);
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
