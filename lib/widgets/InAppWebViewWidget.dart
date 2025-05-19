import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:paytring/paytring_platform_interface.dart';

class InAppWebViewWidget extends StatefulWidget {
  String orderId = "";
  BuildContext dialogueContext;
  var successCallback = () {};
  var failureCallback = () {};
  var eventCallback = () {};
  var removeDialog = () {};

  InAppWebViewWidget(
      {super.key,
      this.orderId = "",
      required this.removeDialog,
      required this.dialogueContext,
      required this.successCallback,
      required this.failureCallback,
      required this.eventCallback});

  @override
  State<InAppWebViewWidget> createState() => _InAppWebViewWidget();
}

class _InAppWebViewWidget extends State<InAppWebViewWidget> {
  @override
  Widget build(BuildContext context) {
    InAppWebViewController? webViewController;

    var html = '''
      <html>
        <head>
          <meta name="viewport" content="user-scalable=no, width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1">
          <script src="http://pay.paytring.com/iframe.v1.0.0.js"></script>
        </head>
        <body>
          <script>
            console.log("Working Here");
            function success() {
              window.flutter_inappwebview.callHandler("PaytringChannel", "success");
            }

            function failure() {
              window.flutter_inappwebview.callHandler("PaytringChannel", "failed");
            }

            function event(data) {
              window.flutter_inappwebview.callHandler("PaytringChannel", "event");
            }

            function close() {
              window.flutter_inappwebview.callHandler("PaytringChannel", "close");
            }

            var options = {
              'order_id': "${widget.orderId}",
              'success': success,
              'failed': failure,
              'events': event,
              'onClose': close,
            };

            console.log("id: ","${widget.orderId}");
            console.log("options: ", options);

            const paytring = new Paytring(options);
            paytring.open();


            function setOTP(otp) {
              const iframe = document.getElementById('paytringframe');
              const iframeContentWindow = iframe?.contentWindow;
              const targetOrigin = 'https://pay.paytring.com';
              iframeContentWindow.postMessage({ type: 'OTP', value: otp }, targetOrigin);
            }
          </script>
        </body>
      </html>
    ''';

    PaytringPlatform.instance.registerOTPListener((String otp) {
      if (webViewController != null) {
        webViewController?.evaluateJavascript(source: "setOTP($otp)");
      }
    });

    void handleSuccess() {
      if (widget.successCallback != null) {
        widget.successCallback();
      }
    }

    void handleFailure() {
      if (widget.failureCallback != null) {
        widget.failureCallback();
      }
    }

    void handleEvent() {
      if (widget.eventCallback != null) {
        widget.eventCallback();
      }
    }

    void handleClose() {
      setState(() {
        widget.removeDialog();
        Navigator.of(context).pop();
      });
    }

    void handleJsMessage(var javaScriptMessage, var webViewController) {
      print(javaScriptMessage);
      switch (javaScriptMessage[0]) {
        case "success":
          handleSuccess();
          handleClose();
          break;
        case "failed":
          handleFailure();
          handleClose();
          break;
        case "event":
          handleEvent();
          break;
        case "close":
          handleClose();
          break;
      }
    }

    void loadHTML() {
      if (webViewController != null) {
        webViewController?.loadData(data: html);
      }
      if (webViewController != null) {
        webViewController?.addJavaScriptHandler(
            handlerName: "PaytringChannel",
            callback: (var javaScriptMessage) =>
                handleJsMessage(javaScriptMessage, webViewController));
      }
    }

    return Scaffold(
      body: InAppWebView(
        onWebViewCreated: (controller) {
          webViewController = controller;
          loadHTML();
        },
      ),
    );
  }
}
