import 'package:bapp/config/constants.dart';
import 'package:bapp/super_strapi/my_strapi/businessX.dart';
import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';
import 'package:bapp/widgets/image/strapi_image.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:simple_strapi/simple_strapi.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

import '../firebase_image.dart';

class BusinessTileBigWidget extends StatelessWidget {
  final Business business;

  final Widget tag;
  final Function()? onTap;

  const BusinessTileBigWidget(
      {Key? key, required this.business, required this.tag, this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, cons) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: cons.maxWidth,
              height: cons.maxWidth * (9 / 16),
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  if (business.partner is Partner)
                    Businesses.listenerWidget(
                      strapiObject: business,
                      sync: true,
                      builder: (_, business, loading) {
                        final images = business.images ?? [];
                        final logo = images.isNotEmpty ? images.first : null;
                        return Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            child: StrapiImage(file: logo),
                          ),
                        );
                      },
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 8),
                    child: tag,
                  )
                ],
              ),
            ),
            if (business is Business)
              BusinessTileWidget(
                branch: business as Business,
                onTap: () {},
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              ),
          ],
        ),
      );
    });
  }
}

class BusinessTileWidget extends StatelessWidget {
  final bool withImage;
  final Business branch;
  final Function()? onTap;
  final EdgeInsets? padding;
  final TextStyle? titleStyle;
  final Function()? onTrailingTapped;

  const BusinessTileWidget(
      {Key? key,
      required this.branch,
      required this.onTap,
      this.padding,
      this.titleStyle,
      this.withImage = false,
      this.onTrailingTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Businesses.listenerWidget(
        strapiObject: branch,
        sync: !branch.synced,
        builder: (_, branch, loading) {
          if (loading) {
            return SizedBox();
          }
          final images = branch.partner?.logo ?? [];
          final image = images.isNotEmpty ? images.first : null;
          return ListTile(
            onTap: onTap,
            dense: true,
            contentPadding: padding ?? EdgeInsets.zero,
            title: Text(
              branch.name ?? "",
              style: titleStyle ??
                  titleStyle ??
                  Theme.of(context).textTheme.headline6,
              maxLines: 1,
            ),
            subtitle: Text(
              // branch.address?.address ?? "",
              branch.address?.locality?.name ?? branch.address?.address ?? "",
              maxLines: 1,
            ),
            leading: withImage
                ? StrapiListTileImageWidget(
                    placeHolder: Initial(
                      forName: branch.name ?? "",
                    ),
                    file: image,
                  )
                : null,
            trailing: GestureDetector(
              onTap: onTrailingTapped,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    (branch.starRating ?? 0).toString(),
                    style: Theme.of(context).textTheme.caption,
                  )
                ],
              ),
            ),
          );
        });
  }
}
