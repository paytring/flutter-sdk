import 'package:flutter/widgets.dart';
import 'package:paytring/paytring_platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebviewWidget extends StatefulWidget {
  String orderId = "";
  BuildContext dialogueContext;
  var successCallback = () {};
  var failureCallback = () {};
  var eventCallback = () {};

  WebviewWidget(
      {super.key,
      this.orderId = "",
      required this.dialogueContext,
      required this.successCallback,
      required this.failureCallback,
      required this.eventCallback});

  @override
  State<WebviewWidget> createState() => _WebviewWidget();
}

class _WebviewWidget extends State<WebviewWidget> {
  PlatformWebViewControllerCreationParams params =
      const PlatformWebViewControllerCreationParams();

  @override
  Widget build(BuildContext context) {
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams
          .fromPlatformWebViewControllerCreationParams(
        params,
      );
    } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams
          .fromPlatformWebViewControllerCreationParams(
        params,
      );
    }

    final WebViewController webViewController =
        WebViewController.fromPlatformCreationParams(
      params,
    );

    webViewController.setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; Mobile; rv:80.0) Gecko/80.0 Firefox/80.0');

    webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);

    webViewController.addJavaScriptChannel("PaytringChannel",
        onMessageReceived: (JavaScriptMessage javaScriptMessage) =>
            handleJsMessage(javaScriptMessage, webViewController));

    webViewController.loadHtmlString('''
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
    ''');

    PaytringPlatform.instance.registerOTPListener((String otp) {
      webViewController.runJavaScript("setOTP($otp)");
    });

    return WillPopScope(
        child: WebViewWidget(controller: webViewController),
        onWillPop: () async {
          handleClose();
          return false;
        });
  }

  handleSuccess() {
    if (widget.successCallback != null) {
      widget.successCallback();
    }
  }

  handleFailure() {
    if (widget.failureCallback != null) {
      widget.failureCallback();
    }
  }

  handleEvent() {
    if (widget.eventCallback != null) {
      widget.eventCallback();
    }
  }

  handleClose() {
    Navigator.of(widget.dialogueContext).pop();
  }

  handleJsMessage(JavaScriptMessage javaScriptMessage,
      WebViewController webViewController) {
    switch (javaScriptMessage.message) {
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
}
