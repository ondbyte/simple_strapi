class BappException implements Exception{
  final String msg;
  final String whatHappened;
  const BappException({this.msg,this.whatHappened});
}

class BappDataBaseError extends BappException{
  BappDataBaseError({String msg,String whatHappened}):super(msg: msg,whatHappened: whatHappened);
}