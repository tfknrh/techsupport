import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:provider/provider.dart';
import 'package:techsupport/controllers/c_customer.dart';
import 'package:techsupport/models/m_customer.dart';
import 'package:techsupport/utils/u_color.dart';
import 'package:techsupport/widgets/w_snackBar.dart';
import 'package:techsupport/widgets/w_text.dart';
import 'package:techsupport/widgets/w_textField.dart';

class AddCustomerScreen extends StatefulWidget {
  final bool isEdit;
  final Customer customer;
  AddCustomerScreen({Key key, this.isEdit = false, this.customer})
      : super(key: key);

  @override
  _AddCustomerScreenState createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  Color _tempShadeColor = Colors.blue[200];
  Color _shadeColor = Colors.blue[800];
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _customerName = TextEditingController();
  TextEditingController _customerDesc = TextEditingController();
  TextEditingController _customerLocation = TextEditingController();
  TextEditingController _customerGPS = TextEditingController();
  TextEditingController _customerPIC = TextEditingController();
  TextEditingController _customerAkses = TextEditingController();
  @override
  void initState() {
    super.initState();
    _setData();
  }

  void _setData() {
    if (widget.isEdit) {
      _customerName.text = widget.customer.customerName;
      _customerDesc.text = widget.customer.customerDesc;
      _customerLocation.text = widget.customer.customerLocation;
      _customerGPS.text = widget.customer.customerGps;
      _customerPIC.text = widget.customer.customerPic;
      _customerAkses.text = widget.customer.customerAkses;
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
    return Consumer<CustomerProvider>(builder: (context, value, _) {
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
              IconButton(
                onPressed: () async {
                  final x = await value.deleteCustomer(widget.customer);
                  if (x.identifier == "success") {
                    Navigator.pop(context);
                    Provider.of<CustomerProvider>(context, listen: false)
                        .obtenerCustomers();
                  } else {
                    SnackBars.showErrorSnackBar(myScaContext, context,
                        Icons.error, "Customer", x.message);
                  }
                },
                icon: Icon(Icons.delete),
              ),
            IconButton(
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  final x = !widget.isEdit
                      ? await value.addCustomer(
                          _customerName.text,
                          _customerDesc.text,
                          _customerLocation.text,
                          _customerGPS.text,
                          _customerPIC.text,
                          _customerAkses.text,
                        )
                      : await value.updateCustomer(
                          widget.customer.customerId,
                          _customerName.text,
                          _customerDesc.text,
                          _customerLocation.text,
                          _customerGPS.text,
                          _customerPIC.text,
                          _customerAkses.text);
                  if (x.identifier == "success") {
                    Navigator.pop(context);
                    Provider.of<CustomerProvider>(context, listen: false)
                        .obtenerCustomers();
                  } else {
                    SnackBars.showErrorSnackBar(myScaContext, context,
                        Icons.error, "Customer", x.message);
                  }
                }
              },
              icon: Icon(Icons.check),
            ),
          ],
          title: Text(
            "${widget.isEdit ? "Ubah" : "Tambah"} Customer",
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
                        label: "Customer Name",
                        radius: 5,
                        controller: _customerName,
                        validator: (e) =>
                            e.isEmpty ? 'Tidak boleh kosong' : null,
                        padding: EdgeInsets.symmetric(
                            vertical: 5, horizontal: _size.width * .02)),
                    SizedBox(
                      height: 20,
                    ),
                    CTextField(
                        label: "Customer Description",
                        inputType: TextInputType.multiline,
                        maxLines: 5,
                        radius: 5,
                        controller: _customerDesc,
                        validator: (e) =>
                            e.isEmpty ? 'Tidak boleh kosong' : null,
                        padding: EdgeInsets.symmetric(
                            vertical: 5, horizontal: _size.width * .02)),
                    SizedBox(
                      height: 20,
                    ),
                    CTextField(
                        label: "Customer Location",
                        radius: 5,
                        controller: _customerLocation,
                        padding: EdgeInsets.symmetric(
                            vertical: 5, horizontal: _size.width * .02)),
                    SizedBox(
                      height: 20,
                    ),
                    CTextField(
                        label: "Customer GPS",
                        radius: 5,
                        controller: _customerGPS,
                        padding: EdgeInsets.symmetric(
                            vertical: 5, horizontal: _size.width * .02)),
                    SizedBox(
                      height: 20,
                    ),
                    CTextField(
                        label: "Customer PIC",
                        radius: 5,
                        controller: _customerPIC,
                        padding: EdgeInsets.symmetric(
                            vertical: 5, horizontal: _size.width * .02)),
                    SizedBox(
                      height: 20,
                    ),
                    CTextField(
                        label: "Customer Akses Remote",
                        radius: 5,
                        controller: _customerAkses,
                        padding: EdgeInsets.symmetric(
                            vertical: 5, horizontal: _size.width * .02)),
                    SizedBox(
                      height: 20,
                    ),
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
