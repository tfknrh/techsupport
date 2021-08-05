import 'package:flutter/material.dart';
import 'package:group_list_view/group_list_view.dart';

import 'package:provider/provider.dart';
import 'package:techsupport/controllers.dart';
import 'package:techsupport/widgets.dart';
import 'package:techsupport/utils.dart';
import 'package:techsupport/models.dart';
import 'package:techsupport/api.dart';
import "package:collection/collection.dart";
import 'dart:convert';

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
  _GroupListScreenState createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<AddFormulirsScreen> {
  // Formulir formulir = Formulir();
  List<Formulir> listFormulir = [];
  List<String> listValue = [];
  List<String> templistValue = [];
  Map<dynamic, List<Formulir>> listdata;
  String _formValue;
  BuildContext myScaContext;
  List<TextEditingController> _controllers = [];
  List<bool> listCheck = [];

  void getListForm() async {
    // listFormulir.clear();
    //  _controllers.clear();
    listFormulir =
        await DataBaseMain.getFormulirByCategoryID(widget.categoryId);

    if (widget.formValue != null) {
      listValue = widget.formValue.split("|");
      for (int i = 0; i < listValue.length; i++) {
        //_controllers.add(new TextEditingController(text: listValue[i]));

        if (listValue[i] != "") {
          listFormulir[i].formValue = listValue[i];
          listFormulir[i].isCheck = true;
        } else {
          listFormulir[i].isCheck = false;
        }

        //  listCheck.add(listValue[i] == "ok" ? true : false);
      }
    } else if (widget.formValue == null) {
      for (int i = 0; i < listFormulir.length; i++) {
        listFormulir[i].isCheck = false;

        //   _controllers.add(new TextEditingController(text: ""));
        //   listFormulir[i].formValue = "";
        // listCheck.add(false);
      }
      // listCheck = List<bool>.filled(listFormulir.length, false);
    }
    listdata = groupBy(listFormulir, (form) => form.formGroup);
    setState(() {});
  }

  dynamic getData(Map data, List<Formulir> way) {
    dynamic dataTemp = data;
    if (way.length > 0) {
      for (int x = 0; x < way.length; x++) {
        dataTemp = dataTemp[way[x]];
      }
    }
    return dataTemp;
  }

  @override
  void initState() {
    super.initState();
    getListForm();
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () async {},
            icon: Icon(Icons.delete),
          ),
          IconButton(
            onPressed: () async {
              // for (int i = 0; i < _controllers.length; i++) {
              //   templistValue.add(_controllers[i].text);
              // }
              listdata.forEach((key, value) {
                templistValue.addAll(value
                    .toList()
                    .map((e) => e.isCheck == true ? e.formValue : ""));
              });

              // for (int i = 0; i <    listFormulir.length; i++) {
              //   templistValue.add(listFormulir[i].formValue);
              // }
              Navigator.pop(context, templistValue);
              Provider.of<AktivitasProvider>(context, listen: false).initData();
              //_controllers.clear();
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: GroupListView(
        sectionsCount: listdata.keys.toList().length,
        countOfItemInSection: (int section) {
          return listdata.values.toList()[section].length;
        },
        itemBuilder: _itemBuilder,
        groupHeaderBuilder: (BuildContext context, int section) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            child: Text(listdata.keys.toList()[section],
                style:
                    CText.primarycustomText(1.8, context, 'CircularStdBold')),
          );
        },
        separatorBuilder: (context, index) =>
            Divider(color: MColors.secondaryTextColor(context)),
        sectionSeparatorBuilder: (context, section) => SizedBox(height: 10),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, IndexPath index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        title: Row(
          children: [
            Expanded(
                flex: 2,
                child: Text(
                    listdata.values
                        .toList()[index.section][index.index]
                        .formName,
                    style: CText.primarycustomText(
                        1.7, context, 'CircularStdBook'))),
            Checkbox(
                value: listdata.values
                    .toList()[index.section][index.index]
                    .isCheck,
                onChanged: (val) {
                  setState(() {
                    listdata.values
                        .toList()[index.section][index.index]
                        .isCheck = val;
                  });
                }),
            Expanded(
              flex: 2,
              child: CTextField(
                  label: listdata.values
                      .toList()[index.section][index.index]
                      .formName,
                  inputType: TextInputType.text,
                  controller: TextEditingController.fromValue(TextEditingValue(
                      text: listdata.values
                                  .toList()[index.section][index.index]
                                  .isCheck ==
                              true
                          ? listdata.values
                              .toList()[index.section][index.index]
                              .formValue
                          : "",
                      selection: new TextSelection.collapsed(
                          offset: listdata.values
                                      .toList()[index.section][index.index]
                                      .isCheck ==
                                  true
                              ? listdata.values
                                  .toList()[index.section][index.index]
                                  .formValue
                                  .length
                              : 0))),
                  function: (text) {
                    listdata.values
                        .toList()[index.section][index.index]
                        .formValue = text;
                  },
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
            ),
          ],
        ),
        //  Text(
        //   listdata.values.toList()[index.section][index.index].formName,
        //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        // ),
        //  trailing: Icon(Icons.arrow_forward_ios),
      ),
      //  ),
    );
  }
}
