import 'package:bapp/classes/firebase_structures/business_services.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/super_strapi/my_strapi/businessX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BusinessProfileServicesTab extends StatefulWidget {
  final Business business;
  const BusinessProfileServicesTab({
    Key? key,
    required this.business,
  }) : super(key: key);
  @override
  _BusinessProfileServicesTabState createState() =>
      _BusinessProfileServicesTabState();
}

class _BusinessProfileServicesTabState
    extends State<BusinessProfileServicesTab> {
  @override
  Widget build(BuildContext context) {
    final catalogs = widget.business.catalogue;
    if (catalogs is! List<ProductCategory>) {
      return Text("ProductCategory  is empty");
    }
    return ListView.builder(
      padding: EdgeInsets.only(top: 15),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: catalogs.length,
      itemBuilder: (_, i) {
        return CatlogueWidget(
          catalogue: catalogs[i],
        );
      },
    );
  }
}

class CatlogueWidget extends StatefulWidget {
  final ProductCategory catalogue;

  const CatlogueWidget({
    Key? key,
    required this.catalogue,
  }) : super(key: key);
  @override
  _CatlogueWidgetState createState() => _CatlogueWidgetState();
}

class _CatlogueWidgetState extends State<CatlogueWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Text(
            widget.catalogue.name ?? "no catalogue name,inform yadu",
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

  List<Widget> _getServicesTiles() {
    final list = <Widget>[];
    widget.catalogue.catalogueItems?.forEach(
      (s) {
        list.add(
          Builder(
            builder: (_) {
              return CatalogueItemWidget(
                item: s,
                bookWidget: bookButton(s),
              );
            },
          ),
        );
      },
    );
    return list;
  }

  Widget bookButton(Product s) {
    return FlatButton(
      onPressed: () {},
      textColor: Theme.of(context).primaryColor,
      child: const Text("Book"),
    );
  }

  Widget cancelBookingButton(Product s) {
    return FlatButton(
      textColor: Theme.of(context).errorColor,
      onPressed: () {},
      child: const Text("Cancel"),
    );
  }
}

class CatalogueItemWidget extends StatelessWidget {
  final Product item;
  final Widget bookWidget;

  const CatalogueItemWidget(
      {Key? key, required this.item, required this.bookWidget})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      title: Text(item.nameOverride ?? "no name, inform yadu"),
      subtitle: _makeSubTitle(context),
      trailing: bookWidget,
      leading: ListTileFirebaseImage(
        ifEmpty: Initial(
          forName: item.nameOverride ?? "no name, inform yadu",
        ),
        storagePathOrURL: (item.imageOverride?.isNotEmpty ?? false)
            ? item.imageOverride?.first.url
            : null,
      ),
    );
  }

  Widget _makeSubTitle(BuildContext context) {
    if (UserX.i.userNotPresent) {
      return SizedBox();
    }

    final user = UserX.i.user();
    final currency = user?.city?.country?.englishCurrencySymbol ??
        "no currency, inform yadu";

    final s = item.price?.toString() ??
        "" +
            " " +
            currency +
            ", " +
            item.duration.toString() +
            " Minutes" +
            "\n" +
            (item.descriptionOverride ?? "");
    return Text(
      s,
      maxLines: 2,
    );
  }
}
