import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Plugin for fetching the app logs
class Logcat {
  /// [MethodChannel] used to communicate with the platform side.
  static const platform = const MethodChannel('com.dtctfk.techsupport/channel');

  /// Fetches the app logs by executing the logcat command-line tool.
  /// May throw [PlatformException] from [MethodChannel].
  static Future<String> execute() async {
    if (Platform.isIOS) {
      return 'Logs can only be fetched from Android Devices presently.';
    }
    String logs;
    try {
      logs = await platform.invokeMethod('execLogcat');
    } on PlatformException catch (e) {
      logs = "Failed to get logs: '${e.message}'.";
    }

    return logs;
  }
}
