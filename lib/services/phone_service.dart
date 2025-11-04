import 'package:url_launcher/url_launcher.dart';

class PhoneService {
  /// Makes a phone call to the given phone number
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        return true;
      } else {
        throw 'Could not launch phone call to $phoneNumber';
      }
    } catch (e) {
      // ignore: avoid_print
      print('[PhoneService] Error launching phone call: $e');
      return false;
    }
  }
}
