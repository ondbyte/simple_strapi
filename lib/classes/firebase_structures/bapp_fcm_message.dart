import 'package:bapp/config/config_data_types.dart';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BappFCMMessage {}

enum MessageOrUpdateType { reminder, bookingUpdate, bookingRating, news }

enum BappFCMMessagePriority { high }
