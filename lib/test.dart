import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TestPage extends StatefulWidget {
  TestPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  static const platform = const MethodChannel('com.dtctfk.techsupport/channel');
  String deviceInfo = "";

  @override
  void initState() {
    _getDeviceInfo();
    super.initState();
  }

  Future<void> _getDeviceInfo() async {
    String result;
    try {
      platform.invokeMethod('getDeviceInfo').then((value) {
        result = value.toString();
        setState(() {
          deviceInfo = result;
        });
      });
    } on PlatformException catch (e) {
      print("_getDeviceInfo==>${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(child: Text(deviceInfo)),
    );
  }
}
