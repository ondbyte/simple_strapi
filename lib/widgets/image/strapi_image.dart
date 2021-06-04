import 'package:bapp/config/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class StrapiImage extends StatelessWidget {
  final StrapiFile? file;
  final BoxFit? fit;
  const StrapiImage({
    Key? key,
    required this.file,
    this.fit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final url = file?.url ?? "$kLogo";
    final myFit = fit ??
        () {
          final width = file?.width ?? 0;
          final height = file?.height ?? 0;
          print("$width$height");
          if (height > width) {
            return BoxFit.cover;
          } else if (width > height) {
            return BoxFit.cover;
          }
          return BoxFit.fitWidth;
        }();
    return SizedBox(
      width: double.maxFinite,
      height: double.maxFinite,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: myFit,
      ),
    );
  }
}

extension StrapiImageExt on StrapiFile {
  StrapiImage imageAsWidget() {
    return StrapiImage(file: this);
  }
}
