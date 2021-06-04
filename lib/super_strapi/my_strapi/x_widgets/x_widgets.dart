import 'package:bapp/config/constants.dart';
import 'package:bapp/super_strapi/my_strapi/x_extensions/strapi_file.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class TapToReFetch<T> extends StatefulWidget {
  final Future<T> Function() fetcher;
  final Function()? onTap;
  final Function(BuildContext, T) onSucessBuilder;
  final Function(BuildContext, Object?, StackTrace?) onErrorBuilder;
  final Function(BuildContext) onLoadBuilder;

  TapToReFetch({
    Key? key,
    required this.fetcher,
    this.onTap,
    required this.onSucessBuilder,
    required this.onErrorBuilder,
    required this.onLoadBuilder,
  }) : super(key: key);

  @override
  _TapToReFetchState<T> createState() => _TapToReFetchState<T>();
}

class _TapToReFetchState<T> extends State<TapToReFetch<T>> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      key: ValueKey("xfbldr"),
      future: widget.fetcher(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasError) {
            return Material(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    widget.onTap?.call();
                  });
                },
                child: widget.onErrorBuilder(
                  context,
                  snap.error,
                  snap.stackTrace,
                ),
              ),
            );
          } else {
            final data = snap.data;
            if (data is T) {
              return widget.onSucessBuilder(context, data);
            }
            return widget.onErrorBuilder(
              context,
              "null",
              StackTrace.current,
            );
          }
        } else {
          return widget.onLoadBuilder(context);
        }
      },
    );
  }
}

class StrapiImageWidget extends StatefulWidget {
  final Widget? placeHolder;
  final StrapiFile? file;
  final StrapiFileFormat? format;
  StrapiImageWidget(
      {Key? key, required this.file, this.placeHolder, this.format})
      : super(key: key);

  @override
  _StrapiImageWidgetState createState() => _StrapiImageWidgetState();
}

class _StrapiImageWidgetState extends State<StrapiImageWidget> {
  String? url;
  @override
  void initState() {
    url = widget.format?.url ?? widget.file?.url;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (url is! String) {
      return widget.placeHolder ?? SizedBox();
    }
    return CachedNetworkImage(
      fit:BoxFit.cover,
      imageUrl: url,
      placeholder: widget.placeHolder is Widget
          ? (_, __) {
              return widget.placeHolder ?? SizedBox();
            }
          : null,
    );
  }
}

class StrapiListTileImageWidget extends StatefulWidget {
  final StrapiFile? file;
  final Widget? placeHolder;
  StrapiListTileImageWidget({Key? key, required this.file, this.placeHolder})
      : super(key: key);

  @override
  _StrapiListTileImageWidgetState createState() =>
      _StrapiListTileImageWidgetState();
}

class _StrapiListTileImageWidgetState extends State<StrapiListTileImageWidget> {
  @override
  Widget build(BuildContext context) {
    return 
       AspectRatio(aspectRatio: 3.5/3,

          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            child: StrapiImageWidget(
              file: widget.file,
              format: widget.file?.thumbNail,
              placeHolder: widget.placeHolder,
            ),
          ),
        
      
    );
  }
}
