import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../config/config.dart';
import '../../helpers/extensions.dart';
import '../../helpers/helper.dart';
import '../../stores/cloud_store.dart';
import '../../widgets/buttons.dart';
import '../../widgets/loading.dart';
import 'package:pedantic/pedantic.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int _selected = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CloudStore>(
        builder: (_, cloudStore, __) {
          return Observer(
            builder: (context) {
              return cloudStore.status == AuthStatus.unsure
                  ? LoadingWidget()
                  : Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(
                            flex: 4,
                          ),
                          CarouselSlider(
                            items: List.generate(
                              OnBoardingConfig.slides.length,
                              (index) => _buildSlide(
                                context,
                                index,
                              ),
                            ),
                            options: CarouselOptions(
                              initialPage: 0,
                              viewportFraction: 1,
                              autoPlay: false,
                              aspectRatio: 1,
                              enableInfiniteScroll: false,
                              enlargeCenterPage: false,
                              onPageChanged: (index, reason) {
                                setState(
                                  () {
                                    //print(index);
                                    _selected = index;
                                  },
                                );
                              },
                            ),
                          ),
                          const Spacer(
                            flex: 2,
                          ),
                          _buildIndicator(
                              context, OnBoardingConfig.slides.length),
                          const Spacer(
                            flex: 1,
                          ),
                        ],
                      ),
                    );
            },
          );
        },
      ),
    );
  }

  Widget _buildIndicator(BuildContext context, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(
        count,
        (index) {
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _selected == index
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlide(BuildContext context, index) {
    var slide = OnBoardingConfig.slides[index];
    return Column(
      children: [
        Expanded(
          child: SvgPicture.asset(
            slide.img,
            width: 256,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          slide.title,
          style: Theme.of(context).textTheme.headline2,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          slide.description,
          style: Theme.of(context).textTheme.bodyText1,
          maxLines: 3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 10,
        ),
        PrimaryButton(
          "Get Started",
          hide: index != OnBoardingConfig.slides.length - 1,
          onPressed: () async {
            ///first time so sign in anonymously
            try {
              await context.read<CloudStore>().signInAnonymous();
            } on FirebaseAuthException catch (e) {
              Helper.printLog(e.toString());
              if (e.code == "network-request-failed") {
                unawaited(
                  Flushbar(
                    message: "No network",
                    mainButton: FlatButton(
                      onPressed: () {
                        Provider.of<CloudStore>(context,listen: false).status = AuthStatus.userNotPresent;
                        BappNavigator.bappPushAndRemoveAll(context, OnBoardingScreen());
                      },
                      child: Text(
                        "Try again",
                        style: Theme.of(context).textTheme.button.apply(
                            color: Theme.of(context).scaffoldBackgroundColor),
                      ),
                    ),
                  ).show(context),
                );
              }
            }
          },
        )
      ],
    );
  }
}
