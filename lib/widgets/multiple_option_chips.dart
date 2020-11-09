import 'package:bapp/widgets/padded_text.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';

class MultipleChipOptionsFormField<T> extends FormField<List<T>> {
  final List<T> items;
  final Function(List<T>) onSaved;
  final Function(List<T>) onChanged;
  final String Function(List<T>) validator;
  final String Function(int, T) itemLabel;
  final List<T> selectedItems;
  final String labelText;

  MultipleChipOptionsFormField(
      {this.selectedItems,
      this.labelText,
      this.onChanged,
      this.itemLabel,
      this.items,
      this.onSaved,
      this.validator,
      Key key})
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
                  ),
                  ChipsChoice<T>.multiple(
                    placeholder: "Please add categories for yor business services to select the user\'s expertise",
                    value: selectedItems,
                    onChanged: (val) {
                      state.didChange(val);
                      onChanged(val);
                    },
                    choiceItems: C2Choice.listFrom<T, T>(
                      source: items,
                      value: (_, v) => v,
                      label: itemLabel,
                    ),
                  ),
                  if (state.hasError)
                    PaddedText(
                      state.errorText,
                      style: Theme.of(state.context)
                          .textTheme
                          .bodyText1
                          .apply(color: Theme.of(state.context).errorColor),
                    ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            );
          },
        );
}
