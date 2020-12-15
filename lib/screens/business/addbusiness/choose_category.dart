
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/business/addbusiness/thank_you_for_your_interest.dart';
import 'package:bapp/screens/misc/contextual_message.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/choose_category.dart';
import 'package:bapp/widgets/login_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class ChooseYourBusinessCategoryScreen extends StatefulWidget {
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
      body: Consumer<CloudStore>(
        builder: (_,cloudStore,__){
          return Observer(
            builder: (_) {
              return cloudStore.status == AuthStatus.userPresent
                  ? Padding(
                padding: EdgeInsets.all(16),
                child: Consumer<BusinessStore>(
                  builder: (_, businessStore,__) {
                    businessStore.getCategories();
                    return Observer(
                      builder: (_) {
                        return AnimatedContainer(
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeInOutSine,
                          child: businessStore.business == null
                              ? Column(
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Choose your business type",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "People will be able to find your business based on these categories.",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ChooseCategoryListTilesWidget(
                                elements: businessStore.categories
                                    .toList(),
                                onCategorySelected: (c) {
                                  BappNavigator.pushReplacement(context, ThankYouForYourInterestScreen(category: c,));

                                },
                              )
                            ],
                          )
                              : _getAlreadyHaveABusiness(context),
                        );
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

  _getAlreadyHaveABusiness(BuildContext context) {
    return ContextualMessageScreen(
      message: "You already have a business on Bapp",
      buttonText: "Switch to Business",
      onButtonPressed: (context) async {
        Provider.of<CloudStore>(context, listen: false).switchUserType(context);
      },
    );
  }
}
