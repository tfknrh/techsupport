import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:techsupport/controllers/c_customer.dart';
import 'package:techsupport/screens/customer/s_addCustomer.dart';
import 'package:techsupport/utils/u_color.dart';
import 'package:techsupport/widgets/w_text.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:animate_do/animate_do.dart';

class CustomersScreen extends StatefulWidget {
  CustomersScreen({Key key}) : super(key: key);

  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  AutoScrollController scrollController = AutoScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    Provider.of<CustomerProvider>(context, listen: false).obtenerCustomers();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Consumer<CustomerProvider>(builder: (context, value, _) {
      return Scaffold(
        backgroundColor: MColors.backgroundColor(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: InkWell(
          onTap: () async {
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.bottomToTop,
                    child: AddCustomerScreen()));
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
          brightness: Theme.of(context).brightness,
          backgroundColor: MColors.backgroundColor(context),
          elevation: 0,
          title: Text(
            "Customer",
            style: CText.primarycustomText(2.5, context, "CircularStdBold"),
          ),
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              value.obtenerCustomers();
            },
            child: ListView.builder(
                //controller: scrollController,
                shrinkWrap: true,
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: false,
                controller: scrollController,
                scrollDirection: Axis.vertical,
                physics: BouncingScrollPhysics(),
                itemCount: value.customer.length,
                itemBuilder: (BuildContext listContext, int index) {
                  return FadeIn(
                    duration: Duration(seconds: 1),
                    animate: true,
                    delay: Duration(milliseconds: index * 1),
                    child: InkWell(
                      onTap: () async {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: AddCustomerScreen(
                                  isEdit: true,
                                  customer: value.customer[index],
                                )));
                      },
                      child: AutoScrollTag(
                        key: ValueKey(index),
                        controller: scrollController,
                        index: index,
                        highlightColor: Colors.black.withOpacity(0.1),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: _size.width * 0.03),
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
                                  offset: Offset(
                                      1, 5), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                              color: MColors.thirdBackgroundColor(context),
                              child: IntrinsicHeight(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Container(
                                      width: _size.width * 0.02,
                                      decoration: BoxDecoration(
                                        color: MColors
                                            .buttonColor(), // value.customer[index].color,
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
                                            vertical: 20,
                                            horizontal: _size.width * 0.05),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Column(
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Text(
                                                            value
                                                                .customer[index]
                                                                .customerName,
                                                            style: CText
                                                                .primarycustomText(
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
                                                            value
                                                                .customer[index]
                                                                .customerLocation,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: CText
                                                                .secondarycustomText(
                                                                    1.5,
                                                                    context,
                                                                    'CircularStdMedium')),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Text(
                                                            value
                                                                .customer[index]
                                                                .customerDesc,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: CText
                                                                .secondarycustomText(
                                                                    1.5,
                                                                    context,
                                                                    'CircularStdMedium')),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              Icons.keyboard_arrow_right,
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color,
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
                      ),
                    ),
                  );
                })),
      );
    });
  }
}
