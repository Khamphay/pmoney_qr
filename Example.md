```dart
import 'package:pmoney_qr/payload.dart';
import 'package:pmoney_qr/pmoney_qr.dart';

final qr = PmoneyQR();

var result = qr.genQRCode(
            "<taget_code>",
            Payload(
                mccCode: "<mcc_code>",
                billId: "<bill_id>",
                amount: 1000,
                expired: "10m"));

debugPrint(result);
// TODO: Use other library for generate the result as QRCode on your Application
```
