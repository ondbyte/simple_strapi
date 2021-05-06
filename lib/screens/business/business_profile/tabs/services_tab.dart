import 'package:bapp/classes/firebase_structures/business_services.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/super_strapi/my_strapi/businessX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BusinessProfileServicesTab extends StatefulWidget {
  final Booking? cart;
  final bool Function()? keepAlive;
  final Business business;
  final Function(List<Product>) onServicesSelected;
  const BusinessProfileServicesTab({
    Key? key,
    required this.business,
    required this.onServicesSelected,
    this.keepAlive,
    this.cart,
  }) : super(key: key);
  @override
  _BusinessProfileServicesTabState createState() =>
      _BusinessProfileServicesTabState();
}

class _BusinessProfileServicesTabState extends State<BusinessProfileServicesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final catalogs = widget.business.catalogue;
    if (catalogs is! List<ProductCategory>) {
      return Text("ProductCategory  is empty");
    }
    return ListView.builder(
      key: ValueKey("lvbldr"),
      padding: EdgeInsets.only(top: 15),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: catalogs.length,
      itemBuilder: (_, i) {
        return CatlogueWidget(
          key: ValueKey("ctlgw"),
          cart: widget.cart,
          catalogue: catalogs[i],
          onServicesSelected: widget.onServicesSelected,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => widget.keepAlive?.call() ?? false;
}

class CatlogueWidget extends StatefulWidget {
  final Booking? cart;
  final ProductCategory catalogue;
  final Function(List<Product>) onServicesSelected;

  const CatlogueWidget({
    Key? key,
    required this.catalogue,
    required this.onServicesSelected,
    this.cart,
  }) : super(key: key);
  @override
  _CatlogueWidgetState createState() => _CatlogueWidgetState();
}

class _CatlogueWidgetState extends State<CatlogueWidget> {
  final _selectedServices = <Product>[];
  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey("bpstpad"),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        key: ValueKey("bpstcol"),
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
            key: ValueKey(s.nameOverride),
            builder: (_) {
              return CatalogueItemWidget(
                key: ValueKey("bfsscfld"),
                item: s,
                selected: widget.cart?.products?.any(
                        (element) => element.nameOverride == s.nameOverride) ??
                    false,
                onRemoved: (p) {
                  _selectedServices.remove(p);
                  widget.onServicesSelected(_selectedServices);
                },
                onSelected: (p) {
                  _selectedServices.add(p);
                  widget.onServicesSelected(_selectedServices);
                },
              );
            },
          ),
        );
      },
    );
    return list;
  }
}

class CatalogueItemWidget extends StatefulWidget {
  final bool selected;
  final Product item;
  final Function(Product) onSelected;
  final Function(Product) onRemoved;

  const CatalogueItemWidget(
      {Key? key,
      required this.item,
      required this.onSelected,
      required this.onRemoved,
      required this.selected})
      : super(key: key);

  @override
  _CatalogueItemWidgetState createState() => _CatalogueItemWidgetState();
}

class _CatalogueItemWidgetState extends State<CatalogueItemWidget> {
  late bool _selected;
  @override
  void initState() {
    _selected = widget.selected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      title: Text(widget.item.nameOverride ?? "no name, inform yadu"),
      subtitle: _makeSubTitle(context),
      trailing: _selected ? cancelBookingButton() : bookButton(),
      leading: widget.item.imageOverride is StrapiFile
          ? StrapiListTileImageWidget(
              placeHolder: Initial(
                forName: widget.item.nameOverride ?? "no name, inform yadu",
              ),
              file: widget.item.imageOverride as StrapiFile)
          : SizedBox(),
    );
  }

  Widget bookButton() {
    return TextButton(
      onPressed: () {
        widget.onSelected(widget.item);
        setState(() {
          _selected = true;
        });
      },
      child: const Text(
        "Book",
      ),
    );
  }

  Widget cancelBookingButton() {
    return TextButton(
      onPressed: () {
        widget.onRemoved(
          widget.item,
        );
        setState(() {
          _selected = false;
        });
      },
      child: const Text("Cancel"),
    );
  }

  Widget _makeSubTitle(BuildContext context) {
    if (UserX.i.userNotPresent) {
      return SizedBox();
    }

    final user = UserX.i.user();
    final currency = user?.city?.country?.englishCurrencySymbol ??
        "no currency, inform yadu";

    final s = widget.item.price?.toString() ??
        "" +
            " " +
            currency +
            ", " +
            widget.item.duration.toString() +
            " Minutes" +
            "\n" +
            (widget.item.descriptionOverride ?? "");
    return Text(
      s,
      maxLines: 2,
    );
  }
}
