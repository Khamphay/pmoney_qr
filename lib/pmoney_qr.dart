library pmoney_qr;

import 'package:pmoney_qr/payload.dart';
import 'package:pmoney_qr/src/gen_qr.dart';

class PmoneyQR {
  final _qr = GenQRCode();
  String genQRCode(String targetCode, Payload payload) =>
      _qr.genQRCode(targetCode, payload);

  void openApp() => _qr.openApp();
}
