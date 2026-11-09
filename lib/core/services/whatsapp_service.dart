import 'package:url_launcher/url_launcher.dart';

import '../utils/formatters.dart';

abstract final class WhatsAppService {
  static Future<bool> openChat({
    required String phone,
    required String message,
  }) async {
    final number = toWhatsAppNumber(phone);
    if (number.isEmpty) return false;
    final uri = Uri.https('wa.me', '/$number', {'text': message});
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'\s'), ''));
    try {
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }
}
