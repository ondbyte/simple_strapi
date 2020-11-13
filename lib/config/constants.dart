import 'dart:math';

import 'package:bapp/config/config_data_types.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

var kAppName = "Bapp";
var kPackageName = "com.bigmints.bapp";
var kRandom = Random();

List<List<MenuItem>> kFilteredMenuItems = [];

///change your terms and privacy policy link here
final kTerms = "https://example.com";
final kPrivacy = "https://example.com";

///maps key
///currently uses the one from bapp not bapp-dev
final kMapsKey = "AIzaSyDp-XSgu-pZdyYRgyLdasTR1FEid_Lh_dA";

final kTemporaryPlaceHolderImage = "assets/svg/ico-spa.svg";
final kTemporaryBusinessImageStorageRefPath = "download.jpeg";

final kUUIDGen = Uuid();

const kDays = [
  "sunday",
  "monday",
  "tuesday",
  "wednesday",
  "thursday",
  "friday",
  "saturday"
];

const kHolidayTypes = [
  "type A",
  "type B",
  "change the options in constants",
];

///global setting to track whether ios notification is enabled
bool kNotifEnabled = false;

class BappFunctions{
  static String sendBappMessage = "sendBappMessage";
}

class BappFunctionsResponse{
  static String success = "success";
  static String multiUser = "multiUser";
  static String noUser = "noUser";
  static String invalidRecipient = "messaging/invalid-recipient";
}
