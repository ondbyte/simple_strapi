import 'package:bapp/config/config.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/buttons.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/store_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int _selected = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoreProvider<AuthStore>(
        store: context.watch<AuthStore>(),
        builder: (context, authStore) {
          return Observer(
            builder: (context) {
              return authStore.status == AuthStatus.unsure
                  ? LoadingWidget()
                  : Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Spacer(
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
                                    print(index);
                                    _selected = index;
                                  },
                                );
                              },
                            ),
                          ),
                          Spacer(
                            flex: 2,
                          ),
                          _buildIndicator(
                              context, OnBoardingConfig.slides.length),
                          Spacer(
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
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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
            fit: BoxFit.fitWidth,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          slide.title,
          style: Theme.of(context).textTheme.headline1,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          slide.description,
          style: Theme.of(context).textTheme.bodyText1,
          maxLines: 3,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 10,
        ),
        PrimaryButton(
          "Get Started",
          hide: index != OnBoardingConfig.slides.length - 1,
          onPressed: () async {
            ///first time so sign in anonymously
            await context.read<AuthStore>().signInAnonymous();
            ///setup user data
            //await await context.read<CloudStore>().init(context.read<AuthStore>());
            ///ask a place
            Navigator.of(context)
                .pushReplacementNamed("/pickaplace", arguments: 0);
          },
        )
      ],
    );
  }
}
