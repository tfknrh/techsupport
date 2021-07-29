import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techsupport/api.dart';
import 'package:techsupport/controllers.dart';
import 'package:techsupport/widgets.dart';
import 'package:techsupport/utils.dart';
import 'package:techsupport/screens.dart';
import 'package:techsupport/models.dart';
import 'package:intl/intl.dart';
import 'package:images_picker/images_picker.dart';
import 'package:extended_image/extended_image.dart';
import 'package:path/path.dart' as path;
import 'package:ext_storage/ext_storage.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

// ignore: must_be_immutable
class AddAktivitas extends StatefulWidget {
  bool isEdit;
  Aktivitas aktivitas;
  AddAktivitas({Key key, this.isEdit = false, this.aktivitas})
      : super(key: key);

  @override
  _AddAktivitasState createState() => _AddAktivitasState();
}

class _AddAktivitasState extends State<AddAktivitas> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _timeStart = TextEditingController();
  TextEditingController _timeFinish = TextEditingController();
  TextEditingController _aktivitasName = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _customerName = TextEditingController();

  TextEditingController _dateTime = TextEditingController();
  Aktivitas aktivitas = Aktivitas();
  bool _ijinNotif = false;
  bool _tipeAktivitas = false;
  bool _isStatus = false;
  Category e;
  Customer c;
  Images images;
  ScrollController _controller = ScrollController();
  List<DropdownMenuItem> _listCustomer = [];
  int _valueCustomer;
  String dateSelected;
  @override
  void initState() {
    //getCustomer();
    String languageCode = Localizations.localeOf(context).toLanguageTag();
    if (!widget.isEdit) {
      aktivitas.dateTime = DateTime.now();
      aktivitas.timeStart = TimeOfDay.now();
      aktivitas.timeFinish = TimeOfDay(
          hour: aktivitas.timeStart.hour,
          minute: aktivitas.timeStart.minute + 1);
      _timeStart.text = TimeValidator.getTimeOfDayS(aktivitas.timeStart);
      // "${TimeValidator.needZero(aktivitas.timeStart.hour)}:${TimeValidator.needZero(aktivitas.timeStart.minute)}";
      _timeFinish.text = TimeValidator.getTimeOfDayS(aktivitas.timeFinish);
      //"${TimeValidator.needZero(aktivitas.timeFinish.hour)}:${TimeValidator.needZero(aktivitas.timeFinish.minute)}";

      _dateTime.text = DateFormat("EEEE, dd MMMM yyyy", languageCode)
          .format(aktivitas.dateTime);
      c = Customer();
      c.customerId = 1;
      dateSelected = DateFormat("yyyy-MM-dd").format(aktivitas.dateTime);
    } else {
      aktivitas.aktivitasId = widget.aktivitas.aktivitasId;
      aktivitas.timeStart = widget.aktivitas.timeStart;
      aktivitas.timeFinish = widget.aktivitas.timeFinish;
      aktivitas.isAlarm = widget.aktivitas.isAlarm;
      aktivitas.notifikasi = widget.aktivitas.notifikasi;
      aktivitas.aktivitasName = widget.aktivitas.aktivitasName;
      aktivitas.description = widget.aktivitas.description;
      aktivitas.dateTime = widget.aktivitas.dateTime;
      aktivitas.aktivitasType = widget.aktivitas.aktivitasType;
      aktivitas.customerId = widget.aktivitas.customerId;
      aktivitas.categoryId = widget.aktivitas.categoryId;
      aktivitas.isStatus = widget.aktivitas.isStatus;
      e = Category();
      e.categoryId = widget.aktivitas.categoryId;
      e.categoryName = widget.aktivitas.categoryName;
      e.color = widget.aktivitas.color;
      c = Customer();
      c.customerId = widget.aktivitas.customerId;
      c.customerName = widget.aktivitas.customerName;
      images = Images();
      images.aktivitasId = widget.aktivitas.aktivitasId;

      _timeStart.text = TimeValidator.getTimeOfDayS(aktivitas.timeStart);
      // "${TimeValidator.needZero(aktivitas.timeStart.hour)}:${TimeValidator.needZero(aktivitas.timeStart.minute)}";
      _timeFinish.text = TimeValidator.getTimeOfDayS(aktivitas.timeFinish);
      //"${TimeValidator.needZero(aktivitas.timeFinish.hour)}:${TimeValidator.needZero(aktivitas.timeFinish.minute)}";
      _description.text = aktivitas.description;

      _dateTime.text = DateFormat("EEEE, dd MMMM yyyy", languageCode)
          .format(aktivitas.dateTime);

      dateSelected = DateFormat("yyyy-MM-dd").format(aktivitas.dateTime);
      _aktivitasName.text = aktivitas.aktivitasName;
      _customerName.text = c.customerName;

      _ijinNotif = aktivitas.notifikasi == 1 ? true : false;
      _tipeAktivitas = aktivitas.aktivitasType == 1 ? true : false;
      _isStatus = aktivitas.isStatus == 2 ? true : false;
      //_valueCustomer = aktivitas.customerId;
    }
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      setState(() {
        print("Shared:" + (_sharedFiles?.map((f) => f.path)?.join(",") ?? ""));
        _sharedFiles = value;
      });
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
      });
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        _sharedText = value;
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      setState(() {
        _sharedText = value;
      });
    });
    getImageList();

    // if (_sharedFiles.length > 0) {
    //   loadShared();
    // }
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    // _ijinNotif = Provider.of<AktivitasProvider>(context, listen: false)
    //     .sharedPrepeferencesGetValueIsNotif();

    setState(() {});
  }

  BuildContext myScaContext;

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    String languageCode = Localizations.localeOf(context).toLanguageTag();
    return Consumer<AktivitasProvider>(builder: (context, value, _) {
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
                  final x = await value.deleteAktivitas(aktivitas);
                  if (x.identifier == "success") {
                    Navigator.pop(context);
                    await Provider.of<AktivitasProvider>(context, listen: false)
                        .initData();
                  } else {
                    SnackBars.showErrorSnackBar(
                        myScaContext, context, Icons.error, "Error", x.message);
                  }
                },
                icon: Icon(Icons.delete),
              ),
            IconButton(
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    if (e == null) {
                      SnackBars.showErrorSnackBar(
                          myScaContext,
                          context,
                          Icons.error,
                          "Kategori",
                          "Tidak ada kategori yang dipilih");
                      return;
                    }

                    final x = !widget.isEdit
                        ? await value.addAktivitas(
                            _aktivitasName.text,
                            _description.text,
                            _timeStart.text + ":00",
                            _timeFinish.text + ":00",
                            dateSelected,
                            _ijinNotif == true && _tipeAktivitas == false
                                ? 1
                                : 0,
                            _tipeAktivitas == true ? 1 : 0,
                            1,
                            e.categoryId == null ? 1 : e.categoryId,
                            c.customerId,
                            _isStatus == true ? 2 : 1)
                        : await value.updateAktivitas(
                            widget.aktivitas.aktivitasId,
                            _aktivitasName.text,
                            _description.text,
                            _timeStart.text + ":00",
                            _timeFinish.text + ":00",
                            dateSelected,
                            _ijinNotif == true && _tipeAktivitas == false
                                ? 1
                                : 0,
                            _tipeAktivitas == true ? 1 : 0,
                            1,
                            e.categoryId == null ? 1 : e.categoryId,
                            c.customerId,
                            _isStatus == true ? 2 : 1);

                    if (x.identifier == "success") {
                      _saveImage();
                      Navigator.pop(context);
                      await Provider.of<AktivitasProvider>(context,
                              listen: false)
                          .initData();
                    } else {
                      SnackBars.showErrorSnackBar(myScaContext, context,
                          Icons.error, "Customer", x.message);
                    }
                  }
                },
                icon: Icon(Icons.save)),
          ],
          title: Text(
            "${widget.isEdit ? "Ubah" : "Tambah"} Aktivitas",
            style: CText.primarycustomText(2.5, context, "CircularStdBold"),
          ),
        ),
        body: Builder(builder: (scaContezt) {
          myScaContext = scaContezt;
          return SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: _size.width * .05),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SizedBox(
                      //   height: 20,
                      // ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(5),
                      //       color: MColors.secondaryBackgroundColor(context)),
                      //   child: Padding(
                      //       padding: EdgeInsets.symmetric(
                      //           horizontal: _size.width * .04),
                      //       child: DropdownButtonHideUnderline(
                      //           child: DropdownButton<int>(
                      //         value: c.customerId,
                      //         isExpanded: true,
                      //         hint: Text("Pilih Nama Customer"),
                      //         items: Provider.of<CustomerProvider>(context,
                      //                 listen: false)
                      //             .customer
                      //             .map<DropdownMenuItem<int>>((value) {
                      //           return DropdownMenuItem<int>(
                      //               value: value.customerId,
                      //               child: Text(value.customerName));
                      //         }).toList(),
                      //         onChanged: (val) {
                      //           c.customerId = val;

                      //           setState(() {});
                      //         },
                      //       ))),
                      // ),
                      SizedBox(
                        height: 20,
                      ),

                      Row(children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              _showModalCustomer(context);
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: IgnorePointer(
                                ignoring: true,
                                child: CTextField(
                                    prefixicon: Icons.people,
                                    label: "Customer",
                                    labelText: "Pilih Customer",
                                    radius: 5,
                                    controller: _customerName,
                                    validator: (e) =>
                                        e.isEmpty ? 'Tidak boleh kosong' : null,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: _size.width * .02)),
                              ),
                            ),
                          ),
                        ),
                      ]),
                      SizedBox(
                        height: 20,
                      ),

                      Row(children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await showDialog(
                                  context: context,
                                  builder: (_) {
                                    return CalendarScreen(
                                      initialDate: value.daySelected,
                                      onDatePressed: (d) {
                                        _dateTime.text = DateFormat(
                                                'EEEE, dd MMMM yyyy',
                                                languageCode)
                                            .format(d)
                                            .toString();
                                        dateSelected = DateFormat('yyyy-MM-dd')
                                            .format(d)
                                            .toString();
                                        Navigator.pop(context);
                                        //   value.setDay2(d);
                                      },
                                    );
                                  }).then((value) {
                                if (value != null) {
                                  aktivitas.dateTime = value;
                                  _dateTime.text = DateFormat(
                                          'EEEE, dd MMMM yyyy', languageCode)
                                      .format(aktivitas.dateTime);
                                  dateSelected = DateFormat('yyyy-MM-dd')
                                      .format(aktivitas.dateTime)
                                      .toString();
                                }
                              });
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: IgnorePointer(
                                ignoring: true,
                                child: CTextField(
                                    prefixicon: Icons.calendar_today,
                                    label: "Tanggal",
                                    labelText: "Tanggal",
                                    radius: 5,
                                    controller: _dateTime,
                                    validator: (e) =>
                                        e.isEmpty ? 'Tidak boleh kosong' : null,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: _size.width * .02)),
                              ),
                            ),
                          ),
                        ),
                      ]),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                showCustomTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  builder:
                                      (BuildContext context, Widget child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        primaryColor: Colors.black,
                                        accentColor: MColors.buttonColor(),
                                      ),
                                      child: child,
                                    );
                                  },
                                ).then((value) {
                                  if (value != null) {
                                    if (value != null) {
                                      aktivitas.timeStart = value;
                                      _timeStart.text =
                                          "${TimeValidator.needZero(aktivitas.timeStart.hour)}:${TimeValidator.needZero(aktivitas.timeStart.minute)}";
                                    }
                                  }
                                });
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: IgnorePointer(
                                  ignoring: true,
                                  child: CTextField(
                                      prefixicon: Icons.alarm,
                                      label: "Mulai",
                                      labelText: "Mulai",
                                      radius: 5,
                                      controller: _timeStart,
                                      validator: (e) => e.isEmpty
                                          ? 'Tidak boleh kosong'
                                          : null,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5,
                                          horizontal: _size.width * .02)),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: _size.width * .04),
                          Expanded(
                              child: GestureDetector(
                                  onTap: () async {
                                    showCustomTimePicker(
                                      initialTime: TimeOfDay.now(),
                                      context: context,
                                      builder:
                                          (BuildContext context, Widget child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            primaryColor: Colors.black,
                                            accentColor: MColors.buttonColor(),
                                          ),
                                          child: child,
                                        );
                                      },
                                    ).then((value) {
                                      if (value != null) {
                                        if (value != null) {
                                          aktivitas.timeFinish = value;
                                          _timeFinish.text =
                                              "${TimeValidator.needZero(aktivitas.timeFinish.hour)}:${TimeValidator.needZero(aktivitas.timeFinish.minute)}";
                                          // ${aktivitas.timeFinish.hour > 11 ? 'PM' : 'AM'}";
                                        }
                                      }
                                    });
                                  },
                                  child: Container(
                                      color: Colors.transparent,
                                      child: IgnorePointer(
                                        ignoring: true,
                                        child: CTextField(
                                            prefixicon: Icons.alarm,
                                            label: "Selesai",
                                            labelText: "Selesai",
                                            controller: _timeFinish,
                                            radius: 5,
                                            validator: (e) => e.isEmpty
                                                ? 'Tidak boleh kosong'
                                                : null,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5,
                                                horizontal: _size.width * .02)),
                                      )))),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      CTextField(
                          // inputType: TextInputType.multilin,
                          //maxLines: 5,
                          label: "Tambahkan Aktivitas",
                          labelText: "Nama Aktivitas",
                          controller: _aktivitasName,
                          radius: 5,
                          validator: (e) =>
                              e.isEmpty ? 'Tidak boleh kosong' : null,
                          padding: EdgeInsets.symmetric(
                              vertical: 5, horizontal: _size.width * .02)),
                      SizedBox(
                        height: 20,
                      ),
                      CTextField(
                          inputType: TextInputType.multiline,
                          maxLines: 5,
                          label: "Tambahkan Deskripsi",
                          labelText: "Deskripsi",
                          controller: _description,
                          radius: 5,
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: _size.width * .02)),
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(children: [
                            Text(
                              "Tambahkan gambar :",
                              style: CText.primarycustomText(
                                  1.7, context, 'CircularStdBook'),
                            ),
                            IconButton(
                                onPressed: () {
                                  // loadAssets();

                                  // loadShared();

                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            ListTile(
                                              leading: new Icon(Icons.photo),
                                              title: new Text('Galeri'),
                                              onTap: () {
                                                pickFromGallery();
                                                Navigator.pop(context);
                                              },
                                            ),
                                            ListTile(
                                              leading:
                                                  new Icon(Icons.music_note),
                                              title: new Text('Camera'),
                                              onTap: () {
                                                pickFromCamera();
                                                Navigator.pop(context);
                                              },
                                            ),
                                            ListTile(
                                              leading: new Icon(Icons.photo),
                                              title: new Text('Shared'),
                                              onTap: () {
                                                loadShared();
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                },
                                icon: Icon(Icons.add_a_photo))
                          ])),
                      getGridView(),
                      pickGridView(),
                      //   listViewPath(),

                      //  shareGridView(),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          children: [
                            Icon(
                              _ijinNotif == true
                                  ? Icons.alarm_on
                                  : Icons.alarm_off,
                              color: MColors.buttonColor(),
                            ),
                            SizedBox(
                              width: _size.width * .02,
                            ),
                            Expanded(
                              child: Text(
                                "Tampilkan Notifikasi",
                                style: CText.primarycustomText(
                                    1.7, context, 'CircularStdBook'),
                              ),
                            ),
                            FlutterSwitch(
                              width: _size.width * 0.12,
                              height: 25.0,
                              inactiveColor:
                                  MColors.secondaryBackgroundColor(context),
                              toggleSize: _size.width * 0.04,
                              value: _ijinNotif,
                              borderRadius: 30.0,
                              activeColor: MColors.buttonColor(),
                              padding: _size.width * 0.01,
                              showOnOff: false,
                              onToggle: (val) {
                                _ijinNotif = val;
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                      Row(children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              children: [
                                Icon(
                                  _tipeAktivitas == true
                                      ? Icons.monitor
                                      : Icons.exit_to_app,
                                  color: MColors.buttonColor(),
                                ),
                                SizedBox(
                                  width: _size.width * .02,
                                ),
                                Expanded(
                                  child: Row(children: [
                                    Text(
                                      _tipeAktivitas == true
                                          ? "Remote"
                                          : "Visit",
                                      style: CText.primarycustomText(
                                          1.7, context, 'CircularStdBook'),
                                    ),
                                  ]),
                                ),
                                FlutterSwitch(
                                  width: _size.width * 0.12,
                                  height: 25.0,
                                  inactiveColor:
                                      MColors.secondaryBackgroundColor(context),
                                  toggleSize: _size.width * 0.04,
                                  value: _tipeAktivitas,
                                  borderRadius: 30.0,
                                  activeColor: MColors.buttonColor(),
                                  padding: _size.width * 0.01,
                                  showOnOff: false,
                                  onToggle: (val) {
                                    _tipeAktivitas = val;
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: _size.width * .04),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              children: [
                                Icon(
                                  _isStatus == false
                                      ? Icons.done
                                      : Icons.done_all,
                                  color: MColors.buttonColor(),
                                  size: 17,
                                ),
                                SizedBox(
                                  width: _size.width * .02,
                                ),
                                Expanded(
                                  child: Row(children: [
                                    Text(
                                      _isStatus == true
                                          ? "Selesai"
                                          : "Belum Selesai",
                                      style: CText.primarycustomText(
                                          1.7, context, 'CircularStdBook'),
                                    ),
                                  ]),
                                ),
                                FlutterSwitch(
                                  width: _size.width * 0.12,
                                  height: 25.0,
                                  inactiveColor:
                                      MColors.secondaryBackgroundColor(context),
                                  toggleSize: _size.width * 0.04,
                                  value: _isStatus,
                                  borderRadius: 30.0,
                                  activeColor: MColors.buttonColor(),
                                  padding: _size.width * 0.01,
                                  showOnOff: false,
                                  onToggle: (val) {
                                    _isStatus = val;
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      ]),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Kategori",
                        style: CText.primarycustomText(
                            1.8, context, "CircularStdMedium"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      e != null
                          ? Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: e.color,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: _size.width * .05,
                                        vertical: 10),
                                    child: Text(
                                      e.categoryName,
                                      style: CText.menucustomText(
                                          1.9, context, "CircularStdBook"),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: _size.width * .03,
                                ),
                                if (e != null)
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      e = null;
                                      setState(() {});
                                    },
                                  ),
                              ],
                            )
                          : SizedBox(
                              height: 45,
                              child: ListView.builder(
                                // shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      e = Provider.of<CategoryProvider>(context,
                                              listen: false)
                                          .category[index];
                                      setState(() {});
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: 10,
                                      ), //_size.width * .0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Provider.of<
                                                            CategoryProvider>(
                                                        context,
                                                        listen: false)
                                                    .category[index]
                                                    .color,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: _size.width * .05,
                                                  vertical: 10),
                                              child: Text(
                                                Provider.of<CategoryProvider>(
                                                        context,
                                                        listen: false)
                                                    .category[index]
                                                    .categoryName,
                                                style: CText.menucustomText(1.9,
                                                    context, "CircularStdBook"),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                itemCount: Provider.of<CategoryProvider>(
                                        context,
                                        listen: false)
                                    .category
                                    .length,
                              ),
                            ),
                    ],
                  ),
                )),
          );
        }),
      );
    });
  }

  List<Customer> _tempList;
  //1
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController textController = new TextEditingController();

  //2
  static List<Customer> _list = [];
  void _showModalCustomer(context) {
    _list = Provider.of<CustomerProvider>(context, listen: false).customer;
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        context: context,
        builder: (context) {
          //3
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return DraggableScrollableSheet(
                maxChildSize: 0.9,
                expand: false,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Column(children: <Widget>[
                    Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(children: <Widget>[
                          Expanded(
                              child: TextField(
                                  controller: textController,
                                  decoration: InputDecoration(
                                    hintText: "Cari Customer",
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    border: InputBorder.none,
                                    filled: true,
                                    hintStyle: TextStyle(
                                        color: MColors.textColor(context)),
                                    fillColor: Colors.grey[200],
                                    focusedErrorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                      borderSide: BorderSide(
                                          color: Color(0xffF9F9F9), width: 3),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                      borderSide: BorderSide(
                                          color: Color(0xffF9F9F9), width: 3),
                                    ),
                                    errorBorder: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    //4
                                    setState(() {
                                      _tempList = _buildSearchList(value);
                                    });
                                  })),
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
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: GestureDetector(

                                    //6
                                    child: (_tempList != null &&
                                            _tempList.length > 0)
                                        ? _showBottomSheetWithSearch(
                                            index, _tempList)
                                        : _showBottomSheetWithSearch(
                                            index, _list),
                                    onTap: () {
                                      //7
                                      c.customerName =
                                          _tempList[index].customerName;
                                      c.customerId =
                                          _tempList[index].customerId;
                                      _customerName.text = c.customerName;
                                      setState(() {});
                                      _scaffoldKey.currentState.showSnackBar(
                                          SnackBar(
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              content: Text(
                                                  (_tempList != null &&
                                                          _tempList.length > 0)
                                                      ? _tempList[index]
                                                          .customerName
                                                      : _list[index]
                                                          .customerName)));
                                      Navigator.of(context).pop();
                                    }));
                          }),
                    )
                  ]);
                });
          });
        });
  }

  //8
  Widget _showBottomSheetWithSearch(int index, List<Customer> listCust) {
    return GestureDetector(
        onTap: () {
          c.customerName = listCust[index].customerName;
          c.customerId = listCust[index].customerId;
          _customerName.text = c.customerName;
          setState(() {});
          Navigator.of(context).pop();
        },
        child: Text(listCust[index].customerName,
            style: CText.primarycustomText(1.7, context, 'CircularStdBook'),
            textAlign: TextAlign.left));
  }

  //9
  List<Customer> _buildSearchList(String userSearchTerm) {
    List<Customer> _searchList = [];

    for (int i = 0; i < _list.length; i++) {
      String name = _list[i].customerName;
      if (name.toLowerCase().contains(userSearchTerm.toLowerCase())) {
        _searchList.add(_list[i]);
      }
    }
    return _searchList;
  }

  Future<File> moveFile(File sourceFile, String newPath) async {
    try {
      // prefer using rename as it is probably faster
      return await sourceFile.rename(newPath);
    } on FileSystemException catch (e) {
      print(e);
      // if rename fails, copy the source file and then delete it
      final newFile = await sourceFile.copy(newPath);
      await sourceFile.delete();
      return newFile;
    }
  }

  List<Images> imageList = [];
  List<File> fileImageArray = [];
  List<String> _listPath = [];

  StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles;

  String _sharedText;
  List<SharedMediaFile> _shared;

  loadShared() async {
    var dir = await ExtStorage.getExternalStorageDirectory();
    if (!Directory("$dir/techsupport/images").existsSync()) {
      Directory("$dir/techsupport/images").createSync(recursive: true);
    }
    if (!mounted) return;
    // showAboutDialog(context: context);
    int _maxImgId = await DataBaseMain.db.maxImgId();
    int id = widget.isEdit == true ? aktivitas.aktivitasId : _maxImgId;
    if (_sharedFiles.length > 0) {
      for (int i = 0; i < _sharedFiles.length; i++) {
        var _ext = path.extension(_sharedFiles[i].path);
        var file = await moveFile(
            File(_sharedFiles[i].path),
            "$dir/techsupport/images/IMG_" +
                id.toString() +
                "_" +
                DateFormat("yyyyMMddHHmmss").format(DateTime.now()).toString() +
                DateTime.now().millisecond.toString() +
                _ext);
        setState(() {
          print(file.path);
          _listPath.add(file.path);
        });
      }
    }
  }

  Widget listViewPath() {
    return _listPath.length == 0
        ? Container()
        : ListView.builder(
            //controller: scrollController,
            shrinkWrap: true,
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: false,
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            itemCount: _listPath.length,
            itemBuilder: (BuildContext listContext, int index) {
              return ListTile(title: Text(_listPath[index]));
            });
  }

  List<Media> _listTempPick = [];
  pickFromGallery() async {
    List<Media> _listGallery = await ImagesPicker.pick(
      count: 5,
      pickType: PickType.all,
      language: Language.English,
      // maxSize: 500,
      // cropOpt: CropOption(
      //  aspectRatio: CropAspectRatio.custom,
      //  ),
    );
    if (_listGallery != null) {
      //print(_listGallery.map((e) => e.path).toList());
      var dir = await ExtStorage.getExternalStorageDirectory();
      if (!Directory("$dir/techsupport/images").existsSync()) {
        Directory("$dir/techsupport/images").createSync(recursive: true);
      }
      if (!mounted) return;
      // showAboutDialog(context: context);
      int _maxImgId = await DataBaseMain.db.maxImgId();
      int id = widget.isEdit == true ? aktivitas.aktivitasId : _maxImgId;
      _listTempPick.addAll(_listGallery);
      for (int i = 0; i < _listGallery.length; i++) {
        var _ext = path.extension(_listGallery[i].path);
        var file = await moveFile(
            File(_listGallery[i].path),
            "$dir/techsupport/images/IMG_" +
                id.toString() +
                "_" +
                DateFormat("yyyyMMddHHmmss").format(DateTime.now()).toString() +
                DateTime.now().millisecond.toString() +
                _ext);

        setState(() {
          print(file.path);
          _listPath.add(file.path);
        });
      }
    }
  }

  pickFromCamera() async {
    List<Media> _listCamera = await ImagesPicker.openCamera(
        //  cropOpt: CropAspectRatio.custom,
        pickType: PickType.image,
        quality: 0.5,
        language: Language.English
        // cropOpt: CropOption(
        //   aspectRatio: CropAspectRatio.wh16x9,
        // ),
        // maxTime: 60,
        );
    if (_listCamera != null) {
      var dir = await ExtStorage.getExternalStorageDirectory();
      if (!Directory("$dir/techsupport/images").existsSync()) {
        Directory("$dir/techsupport/images").createSync(recursive: true);
      }
      if (!mounted) return;
      _listTempPick.addAll(_listCamera);
      // showAboutDialog(context: context);
      int _maxImgId = await DataBaseMain.db.maxImgId();
      int id = widget.isEdit == true ? aktivitas.aktivitasId : _maxImgId;
      for (int i = 0; i < _listCamera.length; i++) {
        var _ext = path.extension(_listCamera[i].path);
        var file = await moveFile(
            File(_listCamera[i].path),
            "$dir/techsupport/images/IMG_" +
                id.toString() +
                "_" +
                DateFormat("yyyyMMddHHmmss").format(DateTime.now()).toString() +
                DateTime.now().millisecond.toString() +
                _ext);

        setState(() {
          print(file.path);
          _listPath.add(file.path);
        });
      }
    }
  }

//image PreView
  Widget shareGridView() {
    return _sharedFiles.length == 0
        ? Container()
        : GridView.count(
            crossAxisCount: 6,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            shrinkWrap: true,
            physics: ScrollPhysics(),
            children: List.generate(_sharedFiles.length, (index) {
              // Asset asset = images[index];
              return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: ExtendedImage.file(
                      File(_sharedFiles[index].path),
                      fit: BoxFit.fitHeight,
                    ),
                  ));
            }));
  }

  Widget pickGridView() {
    return _listPath.length == 0
        ? Container()
        : GridView.count(
            crossAxisCount: 6,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            shrinkWrap: true,
            physics: ScrollPhysics(),
            children: List.generate(_listPath.length, (index) {
              // Asset asset = images[index];
              return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: ExtendedImage.file(
                      File(_listPath[index]),
                      fit: BoxFit.fitHeight,
                    ),
                  ));
            }));
  }

  int count = 0;
  getGridView() {
    return imageList.length == 0
        ? Container()
        : GridView.builder(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemCount: imageList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1),
            itemBuilder: (context, index) {
              return GestureDetector(
                onLongPress: () => _delete(context, imageList[index]),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageDetail(
                        image: imageList[index].imgImage,
                        name: imageList[index].imgName,
                      ),
                    )),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: ExtendedImage.file(
                      File(imageList[index].imgImage),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              );
            },
          );
  }

  void _delete(BuildContext context, Images image) async {
    AlertDialog alertDialog = AlertDialog(
      title: Text("Hapus Image"),
      content: Text("Yakin akan akan menghapus image ini?"),
      actions: [
        ElevatedButton(
          child: Text("Iya"),
          onPressed: () async {
            int result = await DataBaseMain.deleteImages(image);
            if (result != 0) {
              _showSnackBar(context, 'Hapus image berhasil');
              getImageList();
            }
            Navigator.pop(context, true);
          },
        ),
        ElevatedButton(
          child: Text("Tidak"),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ],
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  _saveImage() async {
    try {
      if (_listPath.length > 0) {
        for (int i = 0; i < _listPath.length; i++) {
          int _maxImgId = await DataBaseMain.db.maxImgId();

          Images _images = new Images();
          if (widget.isEdit = true) {
            _images.imgImage = _listPath[i];
            _images.imgName = aktivitas.aktivitasName == null
                ? "tidak ada nama"
                : aktivitas.aktivitasName;
            _images.aktivitasId = aktivitas.aktivitasId;
          } else {
            _images.imgImage = _listPath[i];
            _images.imgName = _aktivitasName.text == null
                ? "tidak ada nama"
                : _aktivitasName.text;
            _images.aktivitasId = _maxImgId;
          }

          await DataBaseMain.db.insetImagesraw(_images);
        }
      }

      _sharedFiles.clear();
      _intentDataStreamSubscription.cancel();
    } on Exception catch (e) {
      _showSnackBar(context, e.toString());
    }
  }

  void getImageList() async {
    if (widget.isEdit == true) {
      imageList =
          await DataBaseMain.getListImagesbyAktId(aktivitas.aktivitasId);
      setState(() {});
    }
  }
}
