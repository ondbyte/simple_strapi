import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessManager {
  final DocumentReference user;
  final DocumentReference belongsToBusiness;
  final List<DocumentReference> maintainsBranches;

  BusinessManager({this.user, this.belongsToBusiness, this.maintainsBranches});
}
