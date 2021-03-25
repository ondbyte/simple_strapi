import 'package:bapp/config/constants.dart';
import 'package:flutter/material.dart';
import 'package:bapp/super_strapi/super_strapi.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

import '../firebase_image.dart';

class BusinessTileBigWidget extends StatelessWidget {
  final Business? branch;
  final Widget tag;
  final Function()? onTap;

  const BusinessTileBigWidget(
      {Key? key, this.branch, required this.tag, this.onTap})
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
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    RRFirebaseStorageImage(
                      fit: BoxFit.contain,
                      storagePathOrURL:
                          branch?.partner?.logo?.isNotEmpty ?? false
                              ? branch?.partner?.logo?.first.url
                              : null,
                      ifEmpty: Initial(
                        forName: branch?.name ?? "zz",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 8),
                      child: tag,
                    )
                  ],
                ),
              ),
            ),
            if (branch is Business)
              BusinessTileWidget(
                branch: branch as Business,
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
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: padding ?? EdgeInsets.zero,
      title: Text(
        branch.name ?? "",
        style: titleStyle,
        maxLines: 1,
      ),
      subtitle: Text(
        branch.address?.address ?? "",
        maxLines: 1,
      ),
      leading: withImage
          ? ListTileFirebaseImage(
              ifEmpty: Initial(
                forName: branch.name ?? "",
              ),
              storagePathOrURL: branch.partner?.logo?.isNotEmpty ?? false
                  ? branch.partner?.logo?.first.url
                  : null,
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
  }
}
