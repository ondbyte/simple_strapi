import 'package:super_strapi_generated/super_strapi_generated.dart';

class BappException implements Exception {
  final String msg;
  final String whatHappened;
  const BappException({this.msg = "", this.whatHappened = ""});
}

class BappDataBaseError extends BappException {
  BappDataBaseError({String msg = "", String whatHappened = ""})
      : super(msg: msg, whatHappened: whatHappened);
}

class BusinessHolidayException extends BappException {
  final Holiday? holiday;

  BusinessHolidayException({required this.holiday});
}

class EmployeeHolidayException extends BappException {
  final String employeeId;

  EmployeeHolidayException({required this.employeeId});
}

class ParameterNotCorrectException extends BappException {
  ParameterNotCorrectException();
}

class EmployeeNotFoundException extends BappException {
  final String employeeId;
  EmployeeNotFoundException({required this.employeeId});
}

class BusinessNotFoundException extends BappException {
  final String businessId;
  BusinessNotFoundException({
    required this.businessId,
  });
}

class EmptyResponseException {}

const parametersNotCorrect = "parameters-are-not-correct";
const businessNotFoundForId = "business-not-found-for-id";
const employeeNotFoundForId = "employee-not-found-for-id";
const businessIsOnHoliday = "business-is-on-holiday";
const employeeIsOnHoliday = "employee-is-on-holiday";

Exception throwExceptionForStrapiResponse(
    String error, Map<dynamic, dynamic> responseData) {
  switch (error) {
    case parametersNotCorrect:
      return ParameterNotCorrectException();
    case businessNotFoundForId:
      return BusinessNotFoundException(businessId: responseData["businessId"]);
    case employeeNotFoundForId:
      return EmployeeNotFoundException(employeeId: responseData["employeeId"]);
    case businessIsOnHoliday:
      return BusinessHolidayException(
          holiday: Holiday.fromMap(responseData["holiday"]));
    case employeeIsOnHoliday:
      return EmployeeHolidayException(employeeId: responseData["employeeId"]);
    default:
      return BappException(msg: "unkown-response-from-server");
  }
}
