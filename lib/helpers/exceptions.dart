import 'package:super_strapi_generated/super_strapi_generated.dart';

class BappException implements Exception {
  final String msg;
  final String whatHappened;
  const BappException({this.msg = "", this.whatHappened = ""});

  @override
  String toString() {
    return "$msg\n$whatHappened";
  }
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

class EmployeeNotBookableException extends BappException {
  final String employeeId;

  EmployeeNotBookableException({required this.employeeId});
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

class EmptyResponseException extends BappException {
  EmptyResponseException({response})
      : super(msg: "empty-response", whatHappened: "the response is $response");
  @override
  String toString() {
    return super.toString();
  }
}

const parametersNotCorrect = "parameters-are-not-correct";
const businessNotFoundForId = "business-not-found-for-id";
const employeeNotFoundForId = "employee-not-found-for-id";
const businessIsOnHoliday = "business-is-on-holiday";
const employeeIsOnHoliday = "employee-is-on-holiday";
const employeeIsNotBookable = "employee-is-not-bookable";

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
    case employeeIsNotBookable:
      return EmployeeNotBookableException(
          employeeId: responseData["employeeId"]);
    default:
      return BappException(msg: "unkown-response-from-server");
  }
}
