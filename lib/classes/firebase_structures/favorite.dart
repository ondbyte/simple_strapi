import 'package:enum_to_string/enum_to_string.dart';

import 'business_branch.dart';
import 'business_details.dart';
import 'business_services.dart';

class Favorite {
  final FavoriteType type;
  final BusinessDetails business;
  final BusinessBranch businessBranch;
  final BusinessService businessService;
  final String id;

  Favorite(
      {this.type,
      this.business,
      this.businessBranch,
      this.businessService,
      this.id});

  toMap() {
    return {
      "type": EnumToString.convertToString(type),
      "business": business?.myDoc?.value,
      "businessBranch": businessBranch?.myDoc?.value,
      "businessService": businessService?.toMap(),
    };
  }
}

enum FavoriteType {
  business,
  businessBranch,
  businessService,
}
