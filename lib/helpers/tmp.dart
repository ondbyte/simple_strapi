import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_country_number_widgets/the_country_number_widgets.dart';
import 'package:thephonenumber/thecountrynumber.dart';

class Tmp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TheCountryNumberInput(
              TheCountryNumber().parseNumber(iso2Code: "IN"),

            ),
          ],
        ),
      ),
    );
  }
}
