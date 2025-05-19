import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:paytring/config/app.dart';
import 'package:paytring/widgets/InAppWebViewWidget.dart';
import 'paytring_platform_interface.dart';
import 'package:http/http.dart';

class Paytring {
  var client = Client();

 
  List<Widget> dialogStack = [];

  void open(BuildContext context, String orderId, var successCallback,
      var failureCallback, var eventCallback) {
    PaytringPlatform.instance.configureMethodHandler();
    if (orderId == null) return;

    Null removeDialog() {
      dialogStack.removeLast();
    }

    dialogStack.add(
      InAppWebViewWidget(
          orderId: orderId,
          removeDialog: removeDialog,
          dialogueContext: context,
          successCallback: successCallback,
          failureCallback: failureCallback,
          eventCallback: eventCallback),
    );

    showDialog(
        context: context,
        builder: (context) {
          return Stack(
            children: dialogStack,
          );
        });

  }
}
