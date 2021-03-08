import 'package:simple_strapi/simple_strapi.dart';

class StrapiInit {
  static final i = StrapiInit._i();

  StrapiInit._i() {
    Strapi.i.host = "api.thebapp.app";
    Strapi.i.shouldUseHttps = true;
  }
}
