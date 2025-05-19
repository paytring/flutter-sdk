import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'paytring_platform_interface.dart';

/// An implementation of [PaytringPlatform] that uses method channels.
class MethodChannelPaytring extends PaytringPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('paytring');
  var subscribers = [];

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> configureMethodHandler() async {
    print("Registering Callback For Handling Methods");
    methodChannel.setMethodCallHandler(methodHandler);
  }

  Future<void> methodHandler(MethodCall call) async {
    final String idea = call.arguments;
    switch (call.method) {
      case "handleOTP": // this method name needs to be the same from invokeMethod in Android
        String otp = call.arguments as String;
        print("Your OTP is ${call.arguments}");
        handleOTP(call.arguments);
        break;
      default:
        print('no method handler for method ${call.method}');
    }
  }

  void handleOTP(String otp) {
    print("Handle OTP is Called");
    print(subscribers);
    subscribers.forEach((element) {
      element(otp);
    });
  }

  bool registerOTPListener(var subscriber) {
    try {
      subscribers.add(subscriber);
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }
}
