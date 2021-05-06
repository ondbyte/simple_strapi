import 'dart:async';

import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:flutter/foundation.dart';
import 'package:get/state_manager.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class PartnerX extends X {
  static final i = PartnerX._x();
  PartnerX._x();

  final partner = Rx<Partner?>(null);

  Future<Partner?> init() async {
    ever(UserX.i.user, (user) async {
      if (user != null) {
        final p = await _getPartnerFromServer(key: ValueKey("1"));
        partner(p);
      } else {
        partner(null);
      }
    });
    final p = await _getPartnerFromServer(key: ValueKey("12"));
    partner(p);
    return partner.value;
  }

  Future<Partner?> _getPartnerFromServer(
      {Key key = const ValueKey("_getPartnerFromServer")}) async {
    return memoize<Partner?>(
      key,
      () async {
        if (UserX.i.userPresent && UserX.i.user()?.partner != null) {
          final id = UserX.i.user()?.partner?.id ?? "";
          if (id.isNotEmpty) {
            return await Partners.findOne(id);
          }
        }
        return null;
      },
    );
  }

  @override
  Future dispose() async {
    await super.dispose();
  }
}
