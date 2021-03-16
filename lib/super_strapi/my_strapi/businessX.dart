import 'package:bapp/helpers/helper.dart';
import 'package:bapp/super_strapi/my_strapi/partnerX.dart';
import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:bapp/super_strapi/super_strapi.dart';
import 'package:get/state_manager.dart';

class BusinessX extends X {
  static final i = BusinessX._x();
  BusinessX._x();

  final businesses = <Business>[].obs;

  Future<List<Business>> init() async {
    ever(PartnerX.i.partner, (partner) async {
      if (partner != null) {
        businesses.clear();
        businesses.addAll(
            await _getPartnerBusinessesFromServer(partner, force: true));
      } else {
        businesses.clear();
      }
    });
    if (PartnerX.i.partner.value != null) {
      businesses.clear();
      businesses.addAll(await _getPartnerBusinessesFromServer(
          PartnerX.i.partner.value,
          force: true));
    }
    return businesses;
  }

  Future<List<Business>> _getPartnerBusinessesFromServer(Partner partner,
      {bool force = false}) async {
    return memoize(
      "_getPartnerBusinessesFromServer",
      () async {
        final ids = partner.businesses.map((e) => e.id) ?? [];
        if (isNullOrEmpty(ids)) {
          bPrint("partner doesnt have businesses");
          return [];
        }
        return [];
      },
      force,
    );
  }

  Future<List<Business>> getNearestBusinesses() async {
    return [];
  }

  @override
  Future dispose() async {
    super.dispose();
  }
}
