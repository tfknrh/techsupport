import 'package:flutter/material.dart';
import 'package:logcat/logcat.dart';
import 'package:techsupport/widgets.dart';
import 'package:techsupport/utils.dart';
import 'package:intl/intl.dart';

class LogPage extends StatefulWidget {
  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  @override
  void initState() {
    super.initState();
    _getLogs();
  }

  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          backgroundColor: MColors.backgroundColor(context),
          elevation: 0,
          title: Text(
            "Log",
            style: CText.primarycustomText(2.5, context, "CircularStdBold"),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  showSearch(
                      context: context,
                      delegate: SearchPage<String>(
                          onQueryUpdate: (s) => print(s),
                          items: listLog,
                          searchLabel: 'Cari Log...',
                          // barTheme: Themes.light,
                          suggestion: Center(
                            child: Text('Filter log'),
                          ),
                          failure: Center(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                Text('Tidak ditemukan log :(',
                                    style: CText.primarycustomText(
                                        1.8, context, 'CircularStdMedium')),
                              ])),
                          filter: (log_) => [log_],
                          builder: (val) => ListView.builder(
                                itemCount: listLog.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text('$val'),
                                  );
                                },
                              )));
                },
                icon: Icon(
                  Icons.search,
                  color: MColors.buttonColor(),
                )),
          ],
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              _getLogs();
            },
            child: ListView.separated(
              controller: scrollController,
              itemCount: listLog.length,
              separatorBuilder: (context, int) {
                return Divider(color: MColors.secondaryTextColor(context));
              },
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${listLog[index]}'),
                );
              },
            )),
      ),
    );
  }

  List<String> listLog = [];

  _getLogs() async {
    final String logs = await Logcat.execute();
    listLog =
        logs.split(DateFormat("MM-dd ").format(DateTime.now()).toString());
    setState(() {});
  }
}
