library pmoney_qr;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pmoney_qr/payload.dart';
import 'package:url_launcher/url_launcher.dart';

import 'hex_code.dart';

class GenQRCode {
  String _qr = '';

  void openApp() async {
    // if (_qr.isEmpty) throw  AssertionError("Not found QR code");
    try {
      await launchUrl(Uri.parse('pmoney://app.pmoney.la/qr/$_qr'),
          mode: LaunchMode.externalApplication);
    } catch (e) {
      rethrow;
    }
  }

  String genQRCode(String targetCode, Payload payload) {
    try {
      const aid = "A005266284662577";
      const iin = "12345678";
      final amount = payload.amount.toString();
      String qrExpired = "";
      final now = DateTime.now();
      final leg = payload.expired.length;
      final exp = int.parse(payload.expired.substring(0, leg - 1));
      final unit = payload.expired.substring(leg - 1, leg).toLowerCase();
      if (unit == "h") {
        qrExpired =
            now.add(Duration(hours: exp)).millisecondsSinceEpoch.toString();
      } else if (unit == "m") {
        qrExpired =
            now.add(Duration(minutes: exp)).millisecondsSinceEpoch.toString();
      } else {
        throw ArgumentError("Expired must include only `h` or `m`.");
      }
      final billId = payload.billId;
      debugPrint(amount);
      var data = [
        _f(ID_PAYLOAD, PAYLOAD_FORMAT_CODE),
        _f(ID_POI_METHOD, POI_METHOD_DYNAMIC),
        _f(
          ID_LAO_QR,
          _serialize([
            _f(AID, aid),
            _f(IIN, iin),
            _f(PAYMENT_TYPE, "002"),
            _f(RECEIVER_ID, targetCode),
            qrExpired.isNotEmpty ? _f(QR_EXPIRE_TIME, qrExpired) : null,
          ]),
        ),
        _f(ID_MERCHANT_CODE, payload.mccCode),
        _f(ID_TRANSACTION_CURRENCY, TRANSACTION_CURRENCY),
        _f(ID_TRANSACTION_AMOUNT, amount),
        _f(ID_ADDITIONAL_INFORMATION, _serialize([_f(ID_B, billId)])),
        _f(ID_COUNTRY_CODE, COUNTRY_CODE),
      ];
      var dataToCrc = '${_serialize(data)}6304';
      data.add(
          _f(ID_CRC, _formatCrc(_crc16xmodem(utf8.encode(dataToCrc), 0xffff))));
      _qr = _serialize(data);
      return _qr;
    } catch (error) {
      rethrow;
    }
  }

  String _f(String id, dynamic value) {
    return [
      id,
      value.toString().padLeft(2, '0').length.toString().padLeft(2, '0'),
      value
    ].join("");
  }

  String _serialize(List<dynamic> xs) {
    return xs.where((x) => x != null).join("");
  }

  String _formatCrc(dynamic crcValue) {
    final d = ("0000${crcValue.toRadixString(16).toUpperCase()}");
    return d.substring(d.length - 4);
  }

  int _crc16xmodem(List<int> current, int previous) {
    int crc = previous;

    for (int index = 0; index < current.length; index++) {
      int code = (crc >> 8) & 0xff;
      code ^= current[index] & 0xff;
      code ^= code >> 4;
      crc = (crc << 8) & 0xffff;
      crc ^= code;
      code = (code << 5) & 0xffff;
      crc ^= code;
      code = (code << 7) & 0xffff;
      crc ^= code;
    }

    return crc;
  }
}
