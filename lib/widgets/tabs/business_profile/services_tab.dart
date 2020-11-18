import 'package:bapp/classes/firebase_structures/business_services.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: sorted.length,
      itemBuilder: (_, i) {
        return BusinessCategoryContainerWidget(
          category: sorted.keys.elementAt(i),
          services: sorted.values.elementAt(i),
        );
      },
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.category.categoryName.value,
            style: Theme.of(context).textTheme.headline1,
          ),
          ..._getServicesTiles(),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  BookingFlow get flow => Provider.of<BookingFlow>(context, listen: false);

  List<Widget> _getServicesTiles() {
    final list = <Widget>[];
    widget.services.forEach(
      (s) {
        list.add(
          Observer(
            builder: (_) {
              return BusinessServiceChildWidget(
                service: s,
                bookWidget: flow.services
                        .any((element) => element.serviceName == s.serviceName)
                    ? cancelBookingButton(s)
                    : bookButton(s),
              );
            },
          ),
        );
      },
    );
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
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      title: Text(service.serviceName.value),
      subtitle: _makeSubTitle(context),
      trailing: bookWidget,
      leading: ListTileFirebaseImage(
        storagePathOrURL: service.images.isNotEmpty
            ? service.images.keys.elementAt(0)
            : kTemporaryPlaceHolderImage,
      ),
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
