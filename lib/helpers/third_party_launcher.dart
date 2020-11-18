import 'package:url_launcher/url_launcher.dart';

class LaunchApp{
  static Future<bool> map(double latitude, double longitude) async {
    var googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      return launch(googleUrl);
    } else {
      return false;
    }
  }
}