import 'dart:math';

import 'package:bapp/config/config_data_types.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

final kTemporaryBusinessImage =
    "https://firebasestorage.googleapis.com/v0/b/bapp-dev-c3849.appspot.com/o/download.jpeg?alt=media&token=5d6f5505-d60f-4912-97a0-abfec74b6787";
final kTemporaryBusinessImageStorageRefPath = "download.jpeg";
