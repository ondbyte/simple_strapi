import 'package:bapp/widgets/padded_text.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';

class MultipleChipOptionsFormField<T> extends FormField<List<T>> {
  final List<T> items;
  @override
  final Function(List<T>?)? onSaved;
  final Function(List<T>)? onChanged;
  @override
  final String Function(List<T>?)? validator;
  final String Function(int, T) itemLabel;
  final List<T> selectedItems;
  final String labelText;
  final String placeHolder;
  final Function()? onAddPressed;

  MultipleChipOptionsFormField(
      {required this.placeHolder,
      required this.onAddPressed,
      required this.selectedItems,
      required this.labelText,
      this.onChanged,
      required this.itemLabel,
      required this.items,
      this.onSaved,
      this.validator,
      Key? key})
      : super(
          key: key,
          autovalidateMode: AutovalidateMode.disabled,
          onSaved: onSaved,
          validator: validator,
          initialValue: [],
          builder: (state) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(state.context).primaryColor.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 8,
                  ),
                  PaddedText(
                    labelText,
                    padding: EdgeInsets.only(left: 8),
                    style: TextStyle(),
                  ),
                  ChipsChoice<T>.multiple(
                    placeholder: placeHolder,
                    value: selectedItems,
                    onChanged: (val) {
                      state.didChange(val);
                      onChanged?.call(val);
                    },
                    choiceItems: C2Choice.listFrom<T, T>(
                      source: items,
                      value: (_, v) => v,
                      label: itemLabel,
                    ),
                  ),
                  if (state.hasError)
                    PaddedText(
                      state.errorText ?? "",
                      padding: EdgeInsets.only(left: 8),
                      style: Theme.of(state.context).textTheme.bodyText1?.apply(
                              color: Theme.of(state.context).errorColor) ??
                          TextStyle(),
                    ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: OutlineButton(
                        child: Text("Add new"), onPressed: onAddPressed),
                  ),
                ],
              ),
            );
          },
        );
}
