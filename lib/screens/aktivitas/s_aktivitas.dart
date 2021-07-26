import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:techsupport/controllers/c_aktivitas.dart';
import 'package:techsupport/models/m_aktivitas.dart';
import 'package:techsupport/screens/aktivitas/s_addAktivitas.dart';
import 'package:techsupport/utils/u_color.dart';
import 'package:techsupport/widgets/w_search_page.dart';

import 'package:techsupport/widgets/w_text.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:animate_do/animate_do.dart';

import 'package:techsupport/utils/u_time.dart';

import 'package:techsupport/logcat.dart';

import 'package:techsupport/screens/category/s_category.dart';

import 'package:theme_mode_handler/theme_mode_handler.dart';
import 'package:techsupport/maproute.dart';
import 'package:techsupport/main.dart' as main;
import 'dart:async';
import 'package:intl/intl.dart';

import 'package:techsupport/utils/themes.dart';
import 'package:techsupport/api/a_db.dart';

import 'package:techsupport/widgets/w_textField.dart';

class AktivitassScreen extends StatefulWidget {
  AktivitassScreen({Key key}) : super(key: key);

  @override
  _AktivitassScreenState createState() => _AktivitassScreenState();
}

class _AktivitassScreenState extends State<AktivitassScreen> {
  AutoScrollController scrollController = AutoScrollController();
  List<Aktivitas> _listData = [];

  TextEditingController _search = TextEditingController();
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    // Timer.periodic(
    //     Duration(seconds: 1),
    //     (Timer t) => //_getTime());
    _initData();
  }

  _initData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<AktivitasProvider>(context, listen: false).initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    String languageCode = Localizations.localeOf(context).toLanguageTag();
    final _size = MediaQuery.of(context).size;
    return Consumer<AktivitasProvider>(builder: (context, value, child) {
      return Scaffold(
        backgroundColor: MColors.backgroundColor(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: InkWell(
          onTap: () async {
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.bottomToTop,
                    child: AddAktivitas(isEdit: false)));
          },
          borderRadius: BorderRadius.circular(300),
          splashColor: Colors.white.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        MColors.main,
                        MColors.main,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        spreadRadius: 0,
                        blurRadius: 11,
                        offset: Offset(1, 5), // changes position of shadow
                      ),
                    ]),
                padding: EdgeInsets.symmetric(
                    horizontal: _size.width * 0.04,
                    vertical: _size.width * 0.04),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                )),
          ),
        ),
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  showSearch(
                      context: context,
                      delegate: SearchPage<Aktivitas>(
                          onQueryUpdate: (s) => print(s),
                          items: value.aktivitas,
                          searchLabel: 'Cari Aktivitas...',
                          // barTheme: Themes.light,
                          suggestion: Center(
                            child: Text('Filter aktivitas'),
                          ),
                          failure: Center(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                Text('Tidak ditemukan aktivitas :('),
                                SizedBox(height: 20),
                                Image.asset(
                                  'assets/images/not_found.png',
                                ),
                              ])),
                          filter: (akt) => [
                                akt.aktivitasName,
                                akt.categoryName,
                                akt.description,
                                akt.customerName,
                                akt.dateTime.toString(),
                              ],
                          builder: (val) => AktivitasItem(
                              akt: val, index: value.aktivitas.indexOf(val))));
                },
                icon: Icon(Icons.search)),
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: Text("Category"),
                    value: 1,
                  ),
                  PopupMenuItem(
                    child: Text("Log"),
                    value: 2,
                  ),
                  PopupMenuItem(
                    child: Text("Map"),
                    value: 3,
                  )
                ];
              },
              onSelected: (value) {
                if (value == 1) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CategorysScreen()));
                } else if (value == 2) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LogPage()));
                } else if (value == 3) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MapPage()));
                }
              },
            )
          ],
          brightness: Theme.of(context).brightness,
          backgroundColor: MColors.backgroundColor(context),
          elevation: 2,
          title: Text(
            "Aktivitas",
            style: CText.primarycustomText(2.5, context, "CircularStdBold"),
          ),
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              value.initData();
            },
            child: ListView(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                children: [
                  ListView.builder(
                      //controller: scrollController,
                      shrinkWrap: true,
                      addAutomaticKeepAlives: true,
                      addRepaintBoundaries: false,
                      controller: scrollController,
                      scrollDirection: Axis.vertical,
                      physics: BouncingScrollPhysics(),
                      itemCount: value.aktivitas.length,
                      itemBuilder: (BuildContext listContext, int index) {
                        return AktivitasItem(
                            akt: value.aktivitas[index], index: index);
                      })
                ])),
      );
    });
  }
}

class AktivitasItem extends StatefulWidget {
  final Function onTap;
  final Function onLongPress;
  final Aktivitas akt;
  final int index;

  const AktivitasItem(
      {Key key, this.onTap, this.onLongPress, this.akt, this.index})
      : super(key: key);

  @override
  _AktivitasItemState createState() => _AktivitasItemState();
}

class _AktivitasItemState extends State<AktivitasItem> {
  AutoScrollController scrollController = AutoScrollController();
  @override
  Widget build(BuildContext context) {
    String languageCode = Localizations.localeOf(context).toLanguageTag();
    final _size = MediaQuery.of(context).size;
    return
        // FadeIn(
        //     duration: Duration(seconds: 1),
        //     animate: true,
        //     delay: Duration(milliseconds: widget.index * 1),
        //     child:
        InkWell(
            onTap: () async {
              // if (widget.akt.aktivitasType == 1)
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.bottomToTop,
                      child: AddAktivitas(
                        isEdit: true,
                        aktivitas: widget.akt,
                      )));
            },
            child: AutoScrollTag(
              key: Key(widget.index.toString()),
              controller: scrollController,
              index: widget.index,
              highlightColor: Colors.black.withOpacity(0.1),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: _size.width * 0.03),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        spreadRadius: 0,
                        blurRadius: 11,
                        offset: Offset(1, 5), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    color:
                        // widget.akt.aktivitasType == 1
                        //   ?
                        MColors.thirdBackgroundColor(context),
                    //  : MColors.navigationBarColor(context),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            width: _size.width * 0.02,
                            decoration: BoxDecoration(
                              color: widget.akt.color,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(0),
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(0)),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: _size.width * 0.05),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                  widget.akt.customerName,
                                                  style:
                                                      CText.primarycustomText(
                                                          1.4,
                                                          context,
                                                          'CircularStdMedium')),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              '${DateFormat("EEEE, dd MMMM yyyy", languageCode).format(widget.akt.dateTime)} | ${TimeValidator.getTimeOfDayS(widget.akt.timeStart)} - ${TimeValidator.getTimeOfDayS(widget.akt.timeFinish)}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: widget.akt.color),
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Icon(
                                              widget.akt.aktivitasType == 1
                                                  ? Icons.monitor
                                                  : Icons.exit_to_app,
                                              color: widget.akt.color,
                                              size: 17,
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Icon(
                                              widget.akt.notifikasi == 1
                                                  ? Icons.alarm_on
                                                  : Icons.alarm_off,
                                              color: widget.akt.color,
                                              size: 17,
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Icon(
                                              widget.akt.isStatus == 2
                                                  ? Icons.done_all
                                                  : Icons.done,
                                              color: widget.akt.color,
                                              size: 17,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                  widget.akt.aktivitasName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style:
                                                      CText.primarycustomText(
                                                          1.8,
                                                          context,
                                                          'CircularStdMedium')),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                  widget.akt.description,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style:
                                                      CText.secondarycustomText(
                                                          1.5,
                                                          context,
                                                          'CircularStdMedium')),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: widget.akt.color,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        _size.width * .02,
                                                    vertical: 5),
                                                child: Text(
                                                  widget.akt.categoryName,
                                                  style: CText.menucustomText(
                                                      1.4,
                                                      context,
                                                      "CircularStdBook"),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_right,
                                    color: Theme.of(context).iconTheme.color,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              //  ),
              // ),
            ));
  }
}