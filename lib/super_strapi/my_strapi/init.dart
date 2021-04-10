import 'package:simple_strapi/simple_strapi.dart';

class StrapiSettings {
  static final i = StrapiSettings._i();

  StrapiSettings._i();

  Future init() async {
    Strapi.i.host = "api.thebapp.app";
    Strapi.i.shouldUseHttps = true;
    Strapi.i.verbose = false;
    Strapi.i.maxListenersForAnObject = 8;
    sPrint(
      "${Strapi.i.host} as host, using ${Strapi.i.shouldUseHttps ? "HTTPS" : "HTTP"} ${Strapi.i.verbose ? ", and is being verbose" : ""}",
    );
  }
}
