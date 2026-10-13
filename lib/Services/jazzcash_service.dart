import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class JazzCashService {
  // COLLEGE PROJECT KE LIYE TEST CREDENTIALS
  static const String merchantId = "MC100001";
  static const String password = "123456";
  static const String integritySalt = "1234567890";
  static const String returnUrl = "https://sandbox.jazzcash.com.pk/ApplicationAPI/API/Payment/DoTransaction";
  static const String postUrl = "https://sandbox.jazzcash.com.pk/CustomerPortal/transactionmanagement/merchantform/";

  static Map<String, String> createPaymentData({required double amount}) {
    String txnRef = "T${DateTime.now().millisecondsSinceEpoch}";
    String dateTime = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
    String expiryDateTime = DateFormat('yyyyMMddHHmmss').format(DateTime.now().add(const Duration(days: 1)));
    
    // JazzCash amount paiso mein leta hai, 100 Rs = 10000
    String ppAmount = (amount * 100).toInt().toString();

    // Hash string ka order JazzCash Docs ke mutabiq hona chahiye
    String hashString = "$integritySalt&$ppAmount&billRef&Description&EN&$merchantId&$password&$returnUrl&PKR&$dateTime&$expiryDateTime&$txnRef&MWALLET&2.0&&&&&";
    
    String secureHash = sha256.convert(utf8.encode(hashString)).toString();

    return {
      'pp_Version': '2.0',
      'pp_TxnType': 'MWALLET',
      'pp_Language': 'EN',
      'pp_MerchantID': merchantId,
      'pp_Password': password,
      'pp_TxnRefNo': txnRef,
      'pp_Amount': ppAmount,
      'pp_TxnCurrency': 'PKR',
      'pp_TxnDateTime': dateTime,
      'pp_TxnExpiryDateTime': expiryDateTime,
      'pp_BillReference': 'billRef',
      'pp_Description': 'Description',
      'pp_ReturnURL': returnUrl,
      'pp_SecureHash': secureHash,
      'ppmpf_1': '',
      'ppmpf_2': '',
      'ppmpf_3': '',
      'ppmpf_4': '',
      'ppmpf_5': '',
    };
  }
}