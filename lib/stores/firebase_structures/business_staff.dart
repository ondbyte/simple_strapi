import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessStaff {
  final DocumentReference user;
  final DocumentReference comesUnderBranch;
  final DocumentReference comesUnderBusiness;
  final DocumentReference comesUnderManger;
  final DocumentReference comesUnderReceptionist;

  BusinessStaff(
      {this.user,
      this.comesUnderBranch,
      this.comesUnderBusiness,
      this.comesUnderManger,
      this.comesUnderReceptionist});
}
