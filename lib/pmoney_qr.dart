library pmoney_qr;

import 'dart:convert';
import 'package:pmoney_qr/payload.dart';

class PmoneyQR {
  String genQRCode(String targetCode, Payload payload) {
    try {
      const aid = "A005266284662577";
      const iin = "12345678";
      final amount = payload.amount.toString();
      String qrExpired = "";
      final now = DateTime.now();
      final leg = payload.expired.length;
      final exp = int.parse(payload.expired.substring(leg - 1));
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

      var data = [
        _f("00", "01"),
        _f("01", "12"),
        _f(
          "38",
          _serialize([
            _f("00", aid),
            _f("01", iin),
            _f("02", "002"),
            _f("03", targetCode),
            qrExpired.isNotEmpty ? _f("04", qrExpired) : null,
          ]),
        ),
        _f("52", payload.mccCode),
        _f("53", "418"),
        _f("54", amount),
        billId.isNotEmpty ? _f("62", _serialize([_f("01", billId)])) : null,
        _f("58", "LA"),
      ];
      var dataToCrc = '${_serialize(data)}6304';
      data.add(
          _f("63", _formatCrc(_crc16xmodem(utf8.encode(dataToCrc), 0xffff))));

      return _serialize(data);
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
    return ("0000${crcValue.toRadixString(16).toUpperCase()}")
        .substring(crcValue.toRadixString(16).length - 4);
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
