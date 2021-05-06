import 'package:flutter/foundation.dart';
import 'package:simple_strapi/simple_strapi.dart';

class StrapiSettings {
  static final i = StrapiSettings._i();

  StrapiSettings._i();

  Future init() async {
    Strapi.i.shouldUseHttps = false;
    Strapi.i.host = "192.168.43.212:1337";
    Strapi.i.verbose = true;
    Strapi.i.maxListenersForAnObject = 8;
    Strapi.i.maxTimeOutInMillis = 30000;
    sPrint(
      "${Strapi.i.host} as host, using ${Strapi.i.shouldUseHttps ? "HTTPS" : "HTTP"} ${Strapi.i.verbose ? ", and is being verbose" : ""}",
    );
  }
}
