import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:provider/provider.dart';
import 'package:techsupport/controllers.dart';
import 'package:techsupport/widgets.dart';
import 'package:techsupport/utils.dart';
import 'package:techsupport/models.dart';

class AddCategoryScreen extends StatefulWidget {
  final bool isEdit;
  final Category customer;
  AddCategoryScreen({Key key, this.isEdit = false, this.customer})
      : super(key: key);

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  Color _tempShadeColor = Colors.blue[200];
  Color _shadeColor = Colors.blue[800];
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _categoryName = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setData();
  }

  void _setData() {
    if (widget.isEdit) {
      _categoryName.text = widget.customer.categoryName;
      _tempShadeColor = widget.customer.color;
      setState(() {});
    }
  }

  void _openDialog(String title, Widget content) {
    showDialog(
      context: context,
      builder: (_) {
        return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              contentPadding: const EdgeInsets.all(6.0),
              backgroundColor: MColors.dialogsColor(context),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text(title),
              content: content,
              actions: [
                ElevatedButton(
                  child: Text('Batal'),
                  onPressed: Navigator.of(context).pop,
                ),
                ElevatedButton(
                  child: Text('Iya'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() => _shadeColor = _tempShadeColor);
                  },
                ),
              ],
            ));
      },
    );
  }

  BuildContext myScaContext;

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Consumer<CategoryProvider>(builder: (context, value, _) {
      return Scaffold(
        backgroundColor: MColors.backgroundColor(context),
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          backgroundColor: MColors.backgroundColor(context),
          elevation: 0,
          centerTitle: false,
          iconTheme: Theme.of(context).iconTheme,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
          actions: [
            if (widget.isEdit)
              if (widget.customer.canDelete == 1)
                IconButton(
                  onPressed: () async {
                    final x = await value.deleteCategory(widget.customer);
                    if (x.identifier == "success") {
                      Navigator.pop(context);
                    } else {
                      SnackBars.showErrorSnackBar(myScaContext, context,
                          Icons.error, "Category", x.message);
                    }
                  },
                  icon: Icon(Icons.delete),
                ),
            IconButton(
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  final x = !widget.isEdit
                      ? await value.addCategory(_categoryName.text, _shadeColor)
                      : await value.updateCategory(widget.customer.categoryId,
                          _categoryName.text, _shadeColor);
                  if (x.identifier == "success") {
                    Navigator.pop(context);
                  } else {
                    SnackBars.showErrorSnackBar(myScaContext, context,
                        Icons.error, "Category", x.message);
                  }
                }
              },
              icon: Icon(Icons.check),
            ),
          ],
          title: Text(
            "${widget.isEdit ? "Ubah" : "Tambah"} Kategori",
            style: CText.primarycustomText(2.5, context, "CircularStdBold"),
          ),
        ),
        body: Builder(builder: (scaContezt) {
          myScaContext = scaContezt;
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _size.width * .05),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    CTextField(
                        label: "Category Name",
                        radius: 5,
                        controller: _categoryName,
                        validator: (e) =>
                            e.isEmpty ? 'Tidak boleh kosong' : null,
                        padding: EdgeInsets.symmetric(
                            vertical: 5, horizontal: _size.width * .02)),
                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: _size.width * .08),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(200),
                            onTap: () {
                              _openDialog(
                                "Select Color",
                                MaterialColorPicker(
                                  shrinkWrap: true,
                                  selectedColor: _shadeColor,
                                  onColorChange: (color) =>
                                      setState(() => _tempShadeColor = color),
                                  onBack: () => print("Back button pressed"),
                                ),
                              );
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _tempShadeColor),
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    _size.width * .05,
                                  ),
                                  child: Icon(
                                    Icons.color_lens,
                                    color: Colors.white,
                                    size: _size.width * .08,
                                  ),
                                )),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }),
      );
    });
  }
}
