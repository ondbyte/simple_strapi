///add or change onboarding slides here
class OnBoardingConfig {
  static List<Slide> slides = [
    ///slide one
    Slide(
      img: "assets/svg/barber.svg",
      title: "Welcome to Bapp",
      description: "Bapp helps you  to discover services & book appointments",
    ),
    ///2
    Slide(
      img: "assets/svg/barber.svg",
      title: "Welcome to Bapp",
      description: "Bapp helps you  to discover services & book appointments",
    ),
    ///3
    Slide(
      img: "assets/svg/barber.svg",
      title: "Welcome to Bapp",
      description: "Bapp helps you  to discover services & book appointments",
    ),
  ];
}

class Slide {
  final String img;
  final String title;
  final String description;
  Slide({this.img, this.title, this.description});
}
