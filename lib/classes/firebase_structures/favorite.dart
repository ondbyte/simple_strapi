import 'package:bapp/classes/firebase_structures/business_branch.dart';
import 'package:bapp/classes/firebase_structures/business_details.dart';
import 'package:bapp/classes/firebase_structures/business_services.dart';
import 'package:enum_to_string/enum_to_string.dart';

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
