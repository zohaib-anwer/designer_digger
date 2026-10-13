import 'package:designerdigger/Services/jazzcash_service.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class JazzCashPaymentScreen extends StatefulWidget {
  final double totalAmount;
  const JazzCashPaymentScreen({super.key, required this.totalAmount});

  @override
  State<JazzCashPaymentScreen> createState() => _JazzCashPaymentScreenState();
}

class _JazzCashPaymentScreenState extends State<JazzCashPaymentScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    var paymentData = JazzCashService.createPaymentData(amount: widget.totalAmount);

    String htmlForm = '''
      <html><body onload="document.forms[0].submit()">
      <form method="post" action="${JazzCashService.postUrl}">
        ${paymentData.entries.map((e) => '<input type="hidden" name="${e.key}" value="${e.value}">').join()}
      </form>
      <p style="text-align:center; margin-top:100px;">Redirecting to JazzCash...</p>
      </body></html>
    ''';

    controller = WebViewController()
     ..setJavaScriptMode(JavaScriptMode.unrestricted)
     ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          // JazzCash success par ye code URL mein bhejta hai: pp_ResponseCode=000
          if (url.contains("pp_ResponseCode=000") || url.contains("000&pp_ResponseMessage")) {
            // Payment successful!
            Navigator.pop(context, true); // true ka matlab hai payment success
          } else if (url.contains("pp_ResponseCode=112") || url.contains("pp_ResponseCode=121")) {
            // Payment Failed
            Navigator.pop(context, false);
          }
        },
      ))
     ..loadHtmlString(htmlForm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pay Rs ${widget.totalAmount.toInt()} via JazzCash")),
      body: WebViewWidget(controller: controller),
    );
  }
}