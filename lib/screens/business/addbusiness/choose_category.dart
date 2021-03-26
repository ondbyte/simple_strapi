import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/business/addbusiness/thank_you_for_your_interest.dart';
import 'package:bapp/screens/misc/contextual_message.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/businessX.dart';
import 'package:bapp/super_strapi/my_strapi/categoryX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/widgets/choose_category.dart';
import 'package:bapp/widgets/login_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class ChooseYourBusinessCategoryScreen extends StatefulWidget {
  final onBoard;
  const ChooseYourBusinessCategoryScreen({Key? key, this.onBoard = false})
      : super(key: key);

  @override
  _ChooseYourBusinessCategoryScreenState createState() =>
      _ChooseYourBusinessCategoryScreenState();
}

class _ChooseYourBusinessCategoryScreenState
    extends State<ChooseYourBusinessCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Builder(
        builder: (_) {
          return Builder(
            builder: (_) {
              return UserX.i.userPresent
                  ? Padding(
                      padding: EdgeInsets.all(16),
                      child: FutureBuilder<List<BusinessCategory>>(
                        future: CategoryX.i.getAllCategories(),
                        builder: (_, snap) {
                          return Builder(
                            builder: (_) {
                              final data = snap.data ?? [];

                              return BusinessX.i.businesses.isEmpty
                                  ? SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Choose ${widget.onBoard ? "the" : "your"} business type",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline1,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            widget.onBoard
                                                ? "Select a Business Category"
                                                : "People will be able to find your business based on these categories.",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1,
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          ChooseCategoryListTilesWidget(
                                            elements: data,
                                            onCategorySelected: (c) {
                                              BappNavigator.pushReplacement(
                                                context,
                                                ThankYouForYourInterestScreen(
                                                    category: c,
                                                    onBoard: widget.onBoard),
                                              );
                                            },
                                          )
                                        ],
                                      ),
                                    )
                                  : _getAlreadyHaveABusiness(context);
                            },
                          );
                        },
                      ),
                    )
                  : AskToLoginWidget(
                      loginReason: "Login to Add a business",
                      secondaryReason:
                          "Logging in will make easy for us to manage your business listing.",
                    );
            },
          );
        },
      ),
    );
  }

  Widget _getAlreadyHaveABusiness(BuildContext context) {
    return ContextualMessageScreen(
      message: "You already have a business on Bapp",
      buttonText: "Switch to Business",
      onButtonPressed: (context) async {},
    );
  }
}
