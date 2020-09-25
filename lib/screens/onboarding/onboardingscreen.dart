import 'package:bapp/config/config.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int _selected = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CarouselSlider(
              items: List.generate(
                OnBoardingConfig.slides.length,
                (index) => _buildSlide(
                  context,
                  OnBoardingConfig.slides[index],
                ),
              ),
              options: CarouselOptions(
                initialPage: 0,
                viewportFraction: 1,
                autoPlay: false,
                aspectRatio: 1,
                enableInfiniteScroll: false,
                enlargeCenterPage: true,
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
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.maxFinite,
              child: FlatButton(
                onPressed: (){},
                child: Text("Proceed"),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            _buildIndicator(context, OnBoardingConfig.slides.length)
          ],
        ),
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

  Widget _buildSlide(BuildContext context, Slide slide) {
    return Column(
      children: [
        Expanded(
            child: SvgPicture.asset(
          slide.img,
          fit: BoxFit.fitWidth,
        )),
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
        )
      ],
    );
  }
}
