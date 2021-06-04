import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class Gallery extends StatefulWidget {
  final List<StrapiFile> images;
  Gallery({Key? key, required this.images}) : super(key: key);

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PhotoViewGallery.builder(
        backgroundDecoration: BoxDecoration(color:Theme.of(context).backgroundColor),
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length,
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded /
                      (event.expectedTotalBytes ?? 1),
            ),
          ),
        ),
        builder: (_, i) {
          return PhotoViewGalleryPageOptions(
            imageProvider: CachedNetworkImageProvider(
              widget.images[i].url,
            ),
            initialScale: PhotoViewComputedScale.contained * 1,
            heroAttributes: PhotoViewHeroAttributes(
              tag: widget.images[i].id!,
            ),
          );
        },
      ),
    );
  }
}
