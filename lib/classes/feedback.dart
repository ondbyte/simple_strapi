class TheFeedBack<T> {
  final TheFeedBackType type;
  final String message;
  final String description;
  String buttonLabel;
  final T variable;
  Function(bool) buttonPressed;
  Function onDismissed;

  TheFeedBack({
    this.variable,
    this.type = TheFeedBackType.normal,
    this.message = "",
    this.description = "",
    this.buttonLabel = "",
    this.onDismissed,
    Function(T) onOkay,
    Function(T) onUndo,
  }) {
    if (buttonLabel == "") {
      if (onUndo != null) {
        buttonLabel = "Undo";
      } else if (onOkay != null) {
        buttonLabel = "OK";
      }
    }
    buttonPressed = (bool undo){
      if(undo){
        if(onUndo!=null){
          onUndo(variable);
        }
      }else{
        if(onOkay!=null) {
          onOkay(variable);
        }
      }
    };
  }
}

enum TheFeedBackType { error, normal }
