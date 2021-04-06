import 'package:super_strapi_generated/super_strapi_generated.dart';

extension Formats on StrapiFile {
  StrapiFileFormats? get thumbNail {
    final thumbnailData = formats?["thumbnail"];
    if (thumbnailData != null) {
      return StrapiFileFormats.fromMap(thumbnailData);
    }
  }

  StrapiFileFormats? get large {
    final thumbnailData = formats?["large"];
    if (thumbnailData != null) {
      return StrapiFileFormats.fromMap(thumbnailData);
    }
  }

  StrapiFileFormats? get medium {
    final thumbnailData = formats?["medium"];
    if (thumbnailData != null) {
      return StrapiFileFormats.fromMap(thumbnailData);
    }
  }

  StrapiFileFormats? get small {
    final thumbnailData = formats?["small"];
    if (thumbnailData != null) {
      return StrapiFileFormats.fromMap(thumbnailData);
    }
  }
}

class StrapiFileFormats {
  final int width;
  final int height;
  final int size;
  final String url;
  final String mime;

  StrapiFileFormats({
    required this.width,
    required this.height,
    required this.size,
    required this.url,
    required this.mime,
  });

  static StrapiFileFormats? fromMap(Map<String, dynamic> map) {
    final width = map["width"];
    final height = map["height"];
    final size = map["size"];
    final url = map["url"];
    final mime = map["mime"];
    if (width is int &&
        height is int &&
        size is int &&
        url is String &&
        mime is String) {
      return StrapiFileFormats(
        width: width,
        height: height,
        size: size,
        url: url,
        mime: mime,
      );
    }
  }
}
