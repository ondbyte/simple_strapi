/* import 'package:enum_to_string/enum_to_string.dart';

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
      "businessService": businessService?.toMap() ?? {},
    };
  }

  @override
  bool operator ==(Object other) {
    if (other is Favorite) {
      return hashCode == other.hashCode;
    }
    return false;
  }

  @override
  int get hashCode {
    switch (type) {
      case FavoriteType.business:
        {
          return business.hashCode;
        }
      case FavoriteType.businessBranch:
        {
          return businessBranch.hashCode;
        }
      case FavoriteType.businessService:
        {
          return businessService.hashCode;
        }
    }
  }
}

enum FavoriteType {
  business,
  businessBranch,
  businessService,
}
 */