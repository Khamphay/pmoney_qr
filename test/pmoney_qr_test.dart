import 'package:flutter_test/flutter_test.dart';
import 'package:pmoney_qr/payload.dart';

import 'package:pmoney_qr/pmoney_qr.dart';

void main() {
  test('adds one to input values', () {
    final qr = PmoneyQR();
    // expect(calculator.addOne(2), 3);
    // expect(calculator.addOne(-7), -6);
    expect(
        qr.genQRCode(
            "",
            Payload(
                mccCode: "mccCode",
                billId: "billId",
                amount: 100,
                expired: "10m")),
        String);
  });
}
