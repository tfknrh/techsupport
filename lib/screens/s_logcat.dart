import 'package:flutter/material.dart';
//import 'package:logcat/logcat.dart';
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
          //  actions: [_searchlog()],
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              _getLogs();
            },
            child: _searchlog()
            //  ListView.separated(
            //   controller: scrollController,
            //   itemCount: _list.length,
            //   separatorBuilder: (context, int) {
            //     return Divider(color: MColors.secondaryTextColor(context));
            //   },
            //   itemBuilder: (context, index) {
            //     return
            //     ListTile(
            //       title: Text('${_list[index]}'),
            //     );
            //   },
            // )
            ),
      ),
    );
  }

  List<String> _list = [];

  _getLogs() async {
    final String logs = await Logcat.execute();
    _list = logs.split(DateFormat("MM-dd ").format(DateTime.now()).toString());
    setState(() {});
  }

  List<String> _tempList;
  //1
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController textController = new TextEditingController();

  //2

  Widget _searchlog() {
    return Column(children: <Widget>[
      Padding(
          padding: EdgeInsets.all(20),
          child: Row(children: <Widget>[
            TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: "Cari Log",
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  border: InputBorder.none,
                  filled: true,
                  hintStyle: TextStyle(color: MColors.textColor(context)),
                  fillColor: MColors.textFieldBackgroundColor(context),
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(
                        color: MColors.backgroundColor(context), width: 3),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(
                        color: MColors.backgroundColor(context), width: 3),
                  ),
                  errorBorder: InputBorder.none,
                ),
                onChanged: (value) {
                  //4
                  setState(() {
                    _tempList = _buildSearchList(value);
                  });
                }),
            IconButton(
                icon: Icon(Icons.close),
                color: Color(0xFF1F91E7),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    textController.clear();
                    _tempList.clear();
                  });
                }),
          ])),
      Expanded(
        child: ListView.separated(
            controller: scrollController,
            //5
            itemCount: (_tempList != null && _tempList.length > 0)
                ? _tempList.length
                : _list.length,
            separatorBuilder: (context, int) {
              return Divider();
            },
            itemBuilder: (context, index) {
              return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: GestureDetector(

                      //6
                      child: (_tempList != null && _tempList.length > 0)
                          ? _showBottomSheetWithSearch(index, _tempList)
                          : _showBottomSheetWithSearch(index, _list),
                      onTap: () {
                        //7

                        setState(() {});
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                                (_tempList != null && _tempList.length > 0)
                                    ? _tempList[index]
                                    : _list[index])));
                        Navigator.of(context).pop();
                      }));
            }),
      )
    ]);
  }

  //8
  Widget _showBottomSheetWithSearch(int index, List<String> listCust) {
    return GestureDetector(
        onTap: () {
          setState(() {});
          Navigator.of(context).pop();
        },
        child: Text(listCust[index],
            style: CText.primarycustomText(1.7, context, 'CircularStdBook'),
            textAlign: TextAlign.left));
  }

  //9
  List<String> _buildSearchList(String userSearchTerm) {
    List<String> _searchList = [];

    for (int i = 0; i < _list.length; i++) {
      String name = _list[i];
      if (name.toLowerCase().contains(userSearchTerm.toLowerCase())) {
        _searchList.add(_list[i]);
      }
    }
    return _searchList;
  }
}
