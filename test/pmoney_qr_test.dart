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
            "ah2CRVQwkjPkTbiTBUDxB4Ume",
            Payload(
                mccCode: "5221",
                billId: DateTime.now().microsecondsSinceEpoch.toString(),
                amount: 1000,
                expired: "10m")),
        isNotEmpty);
  });
}
