import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techsupport/controllers.dart';
import 'package:techsupport/widgets.dart';
import 'package:techsupport/utils.dart';
import 'package:techsupport/models.dart';
import 'package:techsupport/api.dart';

class AddFormulirsScreen extends StatefulWidget {
  final bool isEdit;
  // final Formulir formulir;
  final int aktivitasId;
  final int categoryId;
  final String formValue;
  AddFormulirsScreen(
      {Key key, this.formValue, this.isEdit, this.aktivitasId, this.categoryId})
      : super(key: key);

  @override
  _AddFormulirsScreenState createState() => _AddFormulirsScreenState();
}

class _AddFormulirsScreenState extends State<AddFormulirsScreen> {
  // Formulir formulir = Formulir();
  List<Formulir> listFormulir = [];
  List<String> listValue = [];
  List<String> templistValue = [];
  String _formValue;
  BuildContext myScaContext;
  List<TextEditingController> _controllers = [];
  void getListForm() async {
    // listFormulir.clear();
    //  _controllers.clear();
    listFormulir =
        await DataBaseMain.getFormulirByCategoryID(widget.categoryId);
    if (widget.formValue != null) {
      listValue = widget.formValue.split("|");
      for (int i = 0; i < listValue.length; i++) {
        _controllers.add(new TextEditingController(text: listValue[i]));
      }
    } else if (widget.formValue == null) {
      for (int i = 0; i < listFormulir.length; i++) {
        _controllers.add(new TextEditingController(text: ""));
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    //  Provider.of<FormulirProvider>(context, listen: false).getListFormulirs();
    getListForm();
    // if (widget.isEdit == false) {
    //   for (int i = 0; i < listFormulir.length; i++) {
    //     _controllers.add(new TextEditingController(text: ""));
    //   }
    // } else {

    // }

    // WidgetsFlutterBinding.ensureInitialized();

    //Provider.of<FormulirProvider>(context, listen: false).getListFormulirs();
  }

  //Map<String, int> tempformulir = {};

  // void takeNumber(String text, String itemId) {
  //   try {
  //     int number = int.parse(text);
  //     tempformulir[itemId] = number;
  //     print(tempformulir);
  //   } on FormatException {}
  // }
  @override
  void dispose() {
    _controllers.clear();
    super.dispose();
  }

  _bodyList(List<Formulir> problemList) => ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: problemList.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        _controllers.add(new TextEditingController());
        _controllers[index].text = problemList[index].formValue;

        return Container(
            padding: EdgeInsets.only(top: 0, right: 10, left: 10),
            child: Row(children: <Widget>[
              expandStyle(
                  2,
                  Container(
                      margin: EdgeInsets.only(top: 35),
                      child: Text(problemList[index].formName))),
              expandStyle(
                  1,
                  TextFormField(
                      controller: TextEditingController.fromValue(
                          TextEditingValue(
                              text: problemList[index].formValue,
                              selection: new TextSelection.collapsed(
                                  offset:
                                      problemList[index].formValue.length))),
                      keyboardType: TextInputType.number,
                      onChanged: (String str) {
                        problemList[index].formValue = str;
                        var total = problemList.fold(
                            0,
                            (t, e) =>
                                t +
                                double.parse(
                                    e.formValue.isEmpty ? '0' : e.formValue));
                        print(total);
                      }))
            ]));
      });
  expandStyle(int flex, Widget child) => Expanded(flex: flex, child: child);

  Widget singleItemList(int index) {
    final _size = MediaQuery.of(context).size;
    //Formulir item = listFormulir[index];

    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Text(listFormulir[index].formName,
                      style: CText.primarycustomText(
                          1.7, context, 'CircularStdBook'))),
              Expanded(
                flex: 3,
                child: CTextField(
                    label: listFormulir[index].formName,
                    inputType: TextInputType.text,
                    controller: _controllers[index],
                    // function: (text) {
                    //   formulir.formValue = listFormulir[index].formValue;
                    //   listValue[index] = _controllers[index].text;
                    //  },
                    padding: EdgeInsets.symmetric(
                        vertical: 5, horizontal: _size.width * .02)),
              ),
            ],
          ),
        ));
  }

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    String languageCode = Localizations.localeOf(context).toLanguageTag();

    final _size = MediaQuery.of(context).size;

    //  return Consumer<FormulirProvider>(builder: (context, value, _) {
    return Scaffold(
      backgroundColor: MColors.backgroundColor(context),
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        backgroundColor: MColors.backgroundColor(context),
        elevation: 0,
        title: Text(
          "Formulir " +
              Provider.of<CategoryProvider>(context, listen: false)
                  .category
                  .singleWhere((es) => es.categoryId == widget.categoryId)
                  .categoryName,
          style: CText.primarycustomText(2.5, context, "CircularStdBold"),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              // final x = await value.deleteFormulir(widget.formulir);
              // if (x.identifier == "success") {
              //   Navigator.pop(context);
              // } else {
              //   SnackBars.showErrorSnackBar(myScaContext, context,
              //       Icons.error, "Category", x.message);
              // }
            },
            icon: Icon(Icons.delete),
          ),
          IconButton(
            onPressed: () async {
              //  _formValue = listValue.join("|");
              for (int i = 0; i < _controllers.length; i++) {
                templistValue.add(_controllers[i].text);
              }

              Navigator.pop(context, templistValue);
              Provider.of<AktivitasProvider>(context, listen: false).initData();
              _controllers.clear();
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            //  getListForm();
          },
          child: ListView.separated(
              itemBuilder: (context, index) {
                if (listFormulir.isEmpty) {
                  return CircularProgressIndicator();
                } else {
                  return singleItemList(index);
                }
              },
              separatorBuilder: (context, int) {
                return Divider(color: MColors.secondaryTextColor(context));
              },
              itemCount: listFormulir.length)),

      // ListView.builder(
      //     shrinkWrap: true,
      //     itemCount: itemList.length,
      //     physics: BouncingScrollPhysics(),
      //     itemBuilder: (context, index) {
      //       if (itemList.isEmpty) {
      //         return CircularProgressIndicator();
      //       } else {
      //         return singleItemList(index);
      //       }
      //     }),

      // ),
    );
    // });
  }
}
