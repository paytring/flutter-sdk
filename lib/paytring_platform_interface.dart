import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'paytring_method_channel.dart';

abstract class PaytringPlatform extends PlatformInterface {
  /// Constructs a PaytringPlatform.
  PaytringPlatform() : super(token: _token);

  static final Object _token = Object();

  static PaytringPlatform _instance = MethodChannelPaytring();

  /// The default instance of [PaytringPlatform] to use.
  ///
  /// Defaults to [MethodChannelPaytring].
  static PaytringPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PaytringPlatform] when
  /// they register themselves.
  static set instance(PaytringPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  bool registerOTPListener(var subscriber);
  Future<void> configureMethodHandler();
}
