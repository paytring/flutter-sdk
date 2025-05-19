import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:paytring/paytring_platform_interface.dart';

void openWebview(var orderId, BuildContext buildContext, var successCallback,
    var failureCallback, var eventCallback) {
  InAppWebViewController InAppController;
  HeadlessInAppWebView? headlessInAppWebView = null;
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
              PaytringChannel.postMessage("success");
            }

            function failure() {
              PaytringChannel.postMessage("failed");
            }

            function event(data) {
              PaytringChannel.postMessage("event");
            }

            function close() {
              PaytringChannel.postMessage("close");
            }

            var options = {
              'order_id': "$orderId",
              'success': success,
              'failed': failure,
              'events': event,
              'onClose': close,
            };

            console.log("id: ","$orderId");
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

  handleSuccess() {
    if (successCallback != null) {
      successCallback();
    }
  }

  handleFailure() {
    if (failureCallback != null) {
      failureCallback();
    }
  }

  handleEvent() {
    if (eventCallback != null) {
      eventCallback();
    }
  }

  handleClose() {
    if(headlessInAppWebView != null)  {
      headlessInAppWebView.dispose();
    }
  }

  handleJsMessage(var args, InAppWebViewController webViewController) {
    switch (args[0]) {
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

  headlessInAppWebView = HeadlessInAppWebView(
    onWebViewCreated: (controller) {
      InAppController = controller;
      controller.addJavaScriptHandler(
          handlerName: "PaytringChannel",
          callback: (args) {
            handleJsMessage(args, controller);
          });

      controller.loadData(data: html);
      PaytringPlatform.instance.registerOTPListener((String otp) {
        controller.evaluateJavascript(source: "setOTP($otp)");
      });
    },
    onConsoleMessage: (controller, consoleMessage) {},
    onLoadStart: (controller, url) async {},
    onLoadStop: (controller, url) async {},
  );
}
