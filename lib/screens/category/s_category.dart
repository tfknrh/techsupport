import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:techsupport/controllers/c_category.dart';
import 'package:techsupport/screens/category/s_addCategory.dart';
import 'package:techsupport/utils/u_color.dart';
import 'package:techsupport/widgets/w_text.dart';

class CategorysScreen extends StatefulWidget {
  CategorysScreen({Key key}) : super(key: key);

  @override
  _CategorysScreenState createState() => _CategorysScreenState();
}

class _CategorysScreenState extends State<CategorysScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    Provider.of<CategoryProvider>(context, listen: false).obtenerCategorys();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Consumer<CategoryProvider>(builder: (context, value, _) {
      return Scaffold(
        backgroundColor: MColors.backgroundColor(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: InkWell(
          onTap: () async {
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.bottomToTop,
                    child: AddCategoryScreen()));
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
            "Kategori",
            style: CText.primarycustomText(2.5, context, "CircularStdBold"),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            value.obtenerCategorys();
          },
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.bottomToTop,
                          child: AddCategoryScreen(
                            isEdit: true,
                            customer: value.category[index],
                          )));
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: _size.width * .05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: value.category[index].color,
                            borderRadius: BorderRadius.circular(50)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: _size.width * .05, vertical: 10),
                          child: Text(
                            value.category[index].categoryName,
                            style: CText.menucustomText(
                                1.9, context, "CircularStdBook"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            itemCount: value.category.length,
          ),
        ),
      );
    });
  }
}
