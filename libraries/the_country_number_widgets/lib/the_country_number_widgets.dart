library the_country_number_widgets;

import 'package:flutter/material.dart';
import 'package:thephonenumber/thecountrynumber.dart';

class TheCountryNumberInput extends StatefulWidget {
  final TheNumber existingCountryNumber;
  final Function(TheNumber) customValidator;
  final TheInputDecor decoration;
  final bool showDialCode;
  final Function(TheNumber) onChanged;

  const TheCountryNumberInput(
    this.existingCountryNumber, {
    Key key,
    this.customValidator,
    this.decoration = const TheInputDecor(),
    this.showDialCode = true,
    this.onChanged,
  }) : super(key: key);
  @override
  _TheCountryNumberInputState createState() => _TheCountryNumberInputState();
}

class _TheCountryNumberInputState extends State<TheCountryNumberInput> {
  TheNumber _selectedNumber;
  final _controller = TextEditingController();
  @override
  void initState() {
    assert(widget.existingCountryNumber != null,
        "Initializing number cannot be null");
    _selectedNumber = widget.existingCountryNumber;
    _controller.text = _selectedNumber.number;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ThePrefix(
          existingCountryNumber: _selectedNumber,
          onNewCountrySelected: (tn) {
            if (tn != null) {
              setState(() {
                _selectedNumber = TheCountryNumber()
                    .parseNumber(iso2Code: tn.iso2)
                    .addNumber(_controller.text);
              });
            }
          },
        ),
        Expanded(
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              fillColor: widget.decoration.fillColor,
              labelText: widget.decoration.labelText,
              border: widget.decoration.border,
              hintText: widget.decoration.hintText,
              labelStyle: widget.decoration.labelStyle,
              prefix:
                  widget.showDialCode ? Text(_selectedNumber.dialCode) : null,
            ),
            validator: (s) {
              return widget.customValidator(
                _selectedNumber,
              );
            },
            onChanged: (s) {
              _selectedNumber = TheCountryNumber().parseNumber(
                  internationalNumber: _selectedNumber.dialCode + s);
              widget.onChanged(_selectedNumber);
            },
          ),
        )
      ],
    );
  }
}

class ThePrefix extends StatelessWidget {
  final BorderRadius borderRadius;
  final TheNumber existingCountryNumber;
  final EdgeInsets padding;
  final double width;
  final Function(TheCountry) onNewCountrySelected;

  const ThePrefix(
      {Key key,
      this.borderRadius,
      this.existingCountryNumber,
      this.padding,
      this.width = 32,
      this.onNewCountrySelected})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final countries = TheCountryNumber().countries;
        final _country = await showModalBottomSheet<TheCountry>(
          context: context,
          builder: (context) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: TheCountryPickerList(
                countries: countries,
              ),
            );
          },
        );
        onNewCountrySelected(_country);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: padding ?? const EdgeInsets.only(left: 16),
            child: TheCountryFlag(
              iso2: existingCountryNumber.country.iso2,
            ),
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}

class TheCountryFlag extends StatelessWidget {
  final String iso2;
  final double width;
  final BorderRadius borderRadius;
  const TheCountryFlag({Key key, this.iso2, this.width = 32, this.borderRadius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(6),
        child: Image.asset(
          "country_flags/${(iso2).toLowerCase()}.png",
          package: "the_country_number_widgets",
        ),
      ),
    );
  }
}

class TheCountryPickerList extends StatefulWidget {
  final List<TheCountry> countries;

  const TheCountryPickerList({Key key, this.countries}) : super(key: key);
  @override
  _TheCountryPickerListState createState() => _TheCountryPickerListState();
}

class _TheCountryPickerListState extends State<TheCountryPickerList> {
  var _term = "";

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      shrinkWrap: true,
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (s) {
                    setState(() {
                      _term = s;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        TheSearchResultSliver(
          countries: _getFilteredCountries(),
        )
      ],
    );
  }

  List<TheCountry> _getFilteredCountries() {
    if (_term.isEmpty) {
      return widget.countries;
    }
    return widget.countries
        .where((element) => element.englishName
            .toLowerCase()
            .startsWith(_term.trim().toLowerCase()))
        .toList();
  }
}

class TheSearchResultSliver extends StatelessWidget {
  final List<TheCountry> countries;

  const TheSearchResultSliver({Key key, this.countries}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) {
          return TheCountryTile(
            country: countries[i],
            onTap: () {
              Navigator.of(context).pop(countries[i]);
            },
          );
        },
        childCount: countries.length,
      ),
    );
  }
}

class TheCountryTile extends StatelessWidget {
  final TheCountry country;
  final Function onTap;

  const TheCountryTile({Key key, this.country, this.onTap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: TheCountryFlag(
        iso2: country.iso2,
      ),
      title: Text(country.englishName),
      trailing: const Icon(Icons.keyboard_arrow_right),
    );
  }
}

class TheInputDecor {
  final Color fillColor;
  final String labelText, hintText;
  final InputBorder border;
  final TextStyle labelStyle;
  final BorderRadius prefixBorderRadius;

  const TheInputDecor({
    this.prefixBorderRadius,
    this.fillColor,
    this.labelText = "Enter number",
    this.hintText,
    this.border,
    this.labelStyle,
  });
}
