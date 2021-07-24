import 'package:flutter/material.dart';
import 'dart:async';
import 'package:logcat/logcat.dart';

class LogPage extends StatefulWidget {
  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  String _logs = 'Nothing yet';

  @override
  void initState() {
    super.initState();
    _getLogs();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Log App'),
        ),
        body: SingleChildScrollView(
          child: Text(_logs),
          //         ListView.builder(
          //   itemCount: listLog.length,
          //   itemBuilder: (context, index) {
          //     return ListTile(
          //       title: Text('${listLog[index]}'),
          //     );
          //   },
          // )
        ),
      ),
    );
  }

  List<String> listLog = [];

  Future<void> _getLogs() async {
    final String logs = await Logcat.execute();
    //  var logs = await Logcat.execute();
    // listLog.add(logs);
    setState(() {
      _logs = logs;
    });
  }
}
