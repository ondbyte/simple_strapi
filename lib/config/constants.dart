import 'dart:math';

import 'package:bapp/config/config_data_types.dart';
import 'package:event_bus/event_bus.dart';
import 'package:uuid/uuid.dart';

var kAppName = "Bapp";
var kPackageName = "com.bigmints.bapp";
var kRandom = Random();

List<List<MenuItem>> kFilteredMenuItems = [];

///change your terms and privacy policy link here
final kTerms = "https://www.thebapp.app/terms-of-use.html";
final kPrivacy = "https://www.thebapp.app/privacy-policy.html";

///maps key
///currently uses the one from bapp not bapp-dev
final kMapsKey = "AIzaSyDp-XSgu-pZdyYRgyLdasTR1FEid_Lh_dA";

//final kTemporaryPlaceHolderImage = "assets/svg/ico-spa.svg";

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
  "Public Holiday",
  "Company Holiday",
  "Others",
];

///global setting to track whether ios notification is enabled
bool kNotifEnabled = false;

class BappFunctions {
  static String sendBappMessage = "sendBappMessage";
}

class BappFunctionsResponse {
  static String success = "success";
  static String multiUser = "multiUser";
  static String noUser = "noUser";
  static String invalidRecipient = "messaging/invalid-recipient";
}

final kBus = EventBus();

const kDocumenIntegrityError = "document integrity error";
