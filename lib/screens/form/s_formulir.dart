import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techsupport/controllers.dart';
import 'package:techsupport/widgets.dart';
import 'package:techsupport/utils.dart';
import 'package:techsupport/models.dart';

class FormulirsScreen extends StatefulWidget {
  FormulirsScreen({Key key}) : super(key: key);

  @override
  _FormulirsScreenState createState() => _FormulirsScreenState();
}

class _FormulirsScreenState extends State<FormulirsScreen> {
  Formulir formulir = Formulir();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    Provider.of<FormulirProvider>(context, listen: false).getListFormulirs();
  }

  @override
  Widget build(BuildContext context) {
    String languageCode = Localizations.localeOf(context).toLanguageTag();

    final _size = MediaQuery.of(context).size;

    return Consumer<FormulirProvider>(builder: (context, value, _) {
      return Scaffold(
        backgroundColor: MColors.backgroundColor(context),
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          backgroundColor: MColors.backgroundColor(context),
          elevation: 0,
          title: Text(
            "Formulir",
            style: CText.primarycustomText(2.5, context, "CircularStdBold"),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {},
          child: ListView(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            children: [
              ListView.separated(
                  itemBuilder: (context, index) {
                    return FormulirItem(
                      formulir: value.formulir[index],
                    );
                  },
                  separatorBuilder: (context, int) {
                    return Divider();
                  },
                  itemCount: value.formulir.length)
            ],
          ),
        ),
        // ),
      );
    });
  }
}

class FormulirItem extends StatefulWidget {
  final Function onTap;
  final Function onLongPress;
  final Formulir formulir;
  //final Widget trailing;

  const FormulirItem({Key key, this.onTap, this.onLongPress, this.formulir})
      : super(key: key);

  @override
  _FormulirItemState createState() => _FormulirItemState();
}

class _FormulirItemState extends State<FormulirItem> {
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        left: 40,
        right: 20,
      ),
      child: ListTile(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        title: Row(children: [
          Expanded(
            child: Text(widget.formulir.formName,
                style:
                    CText.primarycustomText(1.7, context, 'CircularStdBook')),
          ),
          SizedBox(width: _size.width * .04),
          Expanded(
            child: CTextField(
                label: widget.formulir.formName,
                radius: 5,
                controller: _controller,
                validator: (e) => e.isEmpty ? 'Tidak boleh kosong' : null,
                padding: EdgeInsets.symmetric(
                    vertical: 5, horizontal: _size.width * .02)),
          )
        ]),
      ),
    );
  }
}
