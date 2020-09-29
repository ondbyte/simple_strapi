import 'package:bapp/helpers/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///add colors of cards across the app (color will be picked up randomely most of the time)
class CardsColor{
  static List<Color> colors = [
    Color(0xff75B79E),
    Color(0xff5A3D55),
    Color(0xffE79C2A),
    Color(0xff1BC3AD),
  ];

  static int last = 0;
  static Color random(){
    last++;
    if(last==colors.length) last = 0;
    return colors[last];
  }
}

///add or change onboarding slides here
class OnBoardingConfig {
  static List<Slide> slides = [
    ///slide one
    Slide(
      img: "assets/svg/barber.svg",
      title: "Welcome to Bapp",
      description: "Bapp helps you  to discover services &\nbook appointments",
    ),

    ///2
    Slide(
      img: "assets/svg/barber.svg",
      title: "Welcome to Bapp",
      description: "Bapp helps you  to discover services &\nbook appointments",
    ),

    ///3
    Slide(
      img: "assets/svg/barber.svg",
      title: "Welcome to Bapp",
      description: "Bapp helps you  to discover services &\nbook appointments",
    ),
  ];
}

///add homescreeen tab names and icons here
class HomeScreenTabsConfig{
  static List<Tab> tabs = [
    Tab(name:"Discover",icon: FeatherIcons.compass,),
    Tab(name:"Bookings",icon: FeatherIcons.calendar,),
    Tab(name:"Favorites",icon: FeatherIcons.heart,),
    Tab(name:"Bookings",icon: FeatherIcons.bell,),
  ];
}

///add home screen featured cards to show
class HomeScreenFeaturedConfig {
  static List<Featured> slides = [
    Featured(
        title:"New On Bapp",
        icon:FeatherIcons.package,
        ref:"",
        cardColor: CardsColor.random()
    ),
    Featured(
        title:"New On Bapp",
        icon:FeatherIcons.package,
        ref:"",
        cardColor: CardsColor.random()
    ),
    Featured(
        title:"New On Bapp",
        icon:FeatherIcons.package,
        ref:"",
        cardColor: CardsColor.random()
    ),
    Featured(
        title:"New On Bapp",
        icon:FeatherIcons.package,
        ref:"",
        cardColor: CardsColor.random()
    ),
  ];
}

class Tab{
  final String name;
  final IconData icon;

  Tab({this.name, this.icon});
}

class Featured {
  final String title;
  final IconData icon;
  final String ref;
  final Color cardColor;

  Featured({this.title, this.icon, this.ref, this.cardColor});
}

class Slide {
  final String img;
  final String title;
  final String description;
  Slide({this.img, this.title, this.description});
}
