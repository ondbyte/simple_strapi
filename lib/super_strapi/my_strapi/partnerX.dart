import 'dart:async';

import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:bapp/super_strapi/super_strapi.dart';
import 'package:get/state_manager.dart';

class PartnerX extends X {
  static final i = PartnerX._x();
  PartnerX._x();

  final Rx<Partner> partner = Rx<Partner>();

  Future<Partner> init() async {
    ever(UserX.i.user, (user) async {
      if (user != null) {
        final p = await _getPartnerFromServer(true);
        partner(p);
      } else {
        partner(null);
      }
    });
    final p = await _getPartnerFromServer(true);
    partner(p);
    return partner.value;
  }

  Future<Partner> _getPartnerFromServer(bool force) async {
    return memoize<Partner>("_getPartnerFromServer", () async {
      if (UserX.i.userPresent && UserX.i.user().partner != null) {
        final id = UserX.i.user().partner.id ?? "";
        if (id.isNotEmpty) {
          return await Partners.findOne(id);
        }
      }
      return null;
    }, force);
  }

  @override
  Future dispose() async {
    await super.dispose();
  }
}
