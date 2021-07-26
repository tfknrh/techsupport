import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techsupport/controllers/c_category.dart';
import 'package:techsupport/controllers/c_aktivitas.dart';
import 'package:techsupport/controllers/c_customer.dart';
//import 'package:techsupport/controllers/c_aktivitas.dart';
import 'package:techsupport/models/m_aktivitas.dart';
import 'package:techsupport/models/m_category.dart';
import 'package:techsupport/models/m_customer.dart';

import 'package:techsupport/models/m_images.dart';
import 'package:techsupport/utils/u_color.dart';
import 'package:techsupport/utils/u_time.dart';
import 'package:techsupport/widgets/w_customSwitch.dart';
import 'package:techsupport/widgets/w_customTimePicker.dart';
import 'package:techsupport/widgets/w_snackBar.dart';
import 'package:techsupport/widgets/w_text.dart';
import 'package:techsupport/widgets/w_textField.dart';

import 'package:techsupport/screens/s_imagedetail.dart';

import 'package:techsupport/widgets/w_calendar.dart';
import 'package:intl/intl.dart';
import 'package:techsupport/api/a_db.dart';
import 'package:techsupport/SQL.dart';

import 'dart:async';
import 'dart:io';

import 'package:techsupport/widgets/images_picker/picker.dart';

import 'package:flutter_absolute_path/flutter_absolute_path.dart';

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

  TextEditingController _dateTime = TextEditingController();
  Aktivitas aktivitas = Aktivitas();
  bool _ijinNotif = false;
  bool _tipeAktivitas = false;
  bool _isStatus = false;
  Category e;
  Customer c;

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

      _timeStart.text = TimeValidator.getTimeOfDayS(aktivitas.timeStart);
      // "${TimeValidator.needZero(aktivitas.timeStart.hour)}:${TimeValidator.needZero(aktivitas.timeStart.minute)}";
      _timeFinish.text = TimeValidator.getTimeOfDayS(aktivitas.timeFinish);
      //"${TimeValidator.needZero(aktivitas.timeFinish.hour)}:${TimeValidator.needZero(aktivitas.timeFinish.minute)}";
      _description.text = aktivitas.description;

      _dateTime.text = DateFormat("EEEE, dd MMMM yyyy", languageCode)
          .format(aktivitas.dateTime);

      dateSelected = DateFormat("yyyy-MM-dd").format(aktivitas.dateTime);
      _aktivitasName.text = aktivitas.aktivitasName;

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
                            _ijinNotif == true ? 1 : 0,
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
                            _ijinNotif == true ? 1 : 0,
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
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: MColors.secondaryBackgroundColor(context)),
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: _size.width * .04),
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                              value: c.customerId,
                              isExpanded: true,
                              hint: Text("Pilih Nama Customer"),
                              items: Provider.of<CustomerProvider>(context,
                                      listen: false)
                                  .customer
                                  .map<DropdownMenuItem<int>>((value) {
                                return DropdownMenuItem<int>(
                                    value: value.customerId,
                                    child: Text(value.customerName));
                              }).toList(),
                              onChanged: (val) {
                                c.customerId = val;

                                setState(() {});
                              },
                            ))),
                      ),
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
                                  loadAssets();

                                  loadShared();
                                },
                                icon: Icon(Icons.add_a_photo))
                          ])),
                      getGridView(),
                      pickGridView(),
                      shareGridView(),
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
                          ?

                          // Container(
                          //     decoration: BoxDecoration(
                          //         color:
                          //             MColors.secondaryBackgroundColor(context),
                          //         borderRadius: BorderRadius.circular(50)),
                          //     child: Padding(
                          //       padding: EdgeInsets.symmetric(
                          //           horizontal: _size.width * .05,
                          //           vertical: 10),
                          //       child: Text(
                          //         'Pilih Kategori',
                          //         style: CText.menucustomText(
                          //             1.9, context, "CircularStdBook"),
                          //       ),
                          //     ),
                          //   )
                          Row(
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
                          :
                          // if (e == null)
                          // SizedBox(
                          //     width: 10,
                          //   ),
                          // if (e == null)
                          SizedBox(
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

  List<ImagesAttrb> imageList = [];
  List<File> fileImageArray = [];
  List<String> f = [];
  List<Asset> resultList = [];
  List<Asset> images = [];
  String error = 'No Error Detected';
  Future<void> loadAssets() async {
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#ff4169e1",
          actionBarTitle: "Pilih Foto",
          allViewTitle: "Semua Foto",
          useDetailsView: true,
          selectCircleStrokeColor: "#ff1e90ff",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }
    var dir = await ExtStorage.getExternalStorageDirectory();
    if (!Directory("$dir/techsupport/images").existsSync()) {
      Directory("$dir/techsupport/images").createSync(recursive: true);
    }
    if (!mounted) return;
    f.clear();
    for (int i = 0; i < resultList.length; i++) {
      var path2 =
          await FlutterAbsolutePath.getAbsolutePath(resultList[i].identifier);
      var _ext = path.extension(path2);
      var file = await moveFile(
          File(path2),
          "$dir/techsupport/images/IMG_" +
              aktivitas.aktivitasId.toString() +
              DateFormat("yyyyMMddHHmmss").format(DateTime.now()).toString() +
              DateTime.now().millisecond.toString() +
              _ext);

      print(file.path);
      f.add(file.path);
    }
    setState(() {
      images = resultList;
    });
    // return fileImageArray;
  }

  StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles;

  String _sharedText;
  List<SharedMediaFile> _shared;

  Future<void> loadShared() async {
    var dir = await ExtStorage.getExternalStorageDirectory();
    if (!Directory("$dir/techsupport/images").existsSync()) {
      Directory("$dir/techsupport/images").createSync(recursive: true);
    }
    if (!mounted) return;
    showAboutDialog(context: context);
    for (int i = 0; i < _sharedFiles.length; i++) {
      var _ext = path.extension(_sharedFiles[i].path);
      // var file = await File(_sharedFiles[i].path).rename(
      //     "$dir/techsupport/images/IMG_" +
      //         aktivitas.aktivitasId.toString() +
      //         DateFormat("yyyyMMddHHmmss").format(DateTime.now()).toString() +
      //         DateTime.now().millisecond.toString() +
      //         _ext);
      var file = await moveFile(
          File(_sharedFiles[i].path),
          "$dir/techsupport/images/IMG_" +
              aktivitas.aktivitasId.toString() +
              DateFormat("yyyyMMddHHmmss").format(DateTime.now()).toString() +
              DateTime.now().millisecond.toString() +
              _ext);

      print(file.path);
      f.add(file.path);
    }
    // setState(() {
    //   _shared = _sharedFiles;
    // });
    // return fileImageArray;
  }

  Widget listPath() {
    return f.length == 0
        ? Container()
        : ListView.builder(
            //controller: scrollController,
            shrinkWrap: true,
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: false,
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            itemCount: f.length,
            itemBuilder: (BuildContext listContext, int index) {
              return ListTile(title: Text(f[index]));
            });
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
    return images.length == 0
        ? Container()
        : GridView.count(
            crossAxisCount: 6,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            shrinkWrap: true,
            physics: ScrollPhysics(),
            children:

                //  widget.aktrd == null?
                List.generate(images.length, (index) {
              Asset asset = images[index];
              return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2)),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: AssetThumb(
                        asset: asset,
                        width: 700,
                        height: 700,
                      )));
            })

            // : imageList.map((photo) {
            //     return Utility.imageFromBase64String(photo.imgImage);
            //   }).toList(),
            );
  }

  int count = 0;
  getGridView() {
    return imageList.length == 0
        ? Container()
        : GridView.builder(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemCount: count,
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
                    child:
                        // ExtendedImage.memory(
                        //   Utility.dataFromBase64String(imageList[index].imgImage),
                        //   fit: BoxFit.fitHeight,
                        // ),
                        ExtendedImage.file(
                      File(imageList[index].imgImage),
                      fit: BoxFit.fitHeight,
                    ),
                    //Utility.imageFromBase64String(imageList[index].imgImage),
                  ),
                  //  Image.file(File(imageList[index].imgImage),
                  //   fit: BoxFit.cover,
                  //  ),
                  //  ),
                ),
              );
            },
          );
  }

  void _delete(BuildContext context, ImagesAttrb image) async {
    AlertDialog alertDialog = AlertDialog(
      title: Text("Hapus Image"),
      content: Text("Yakin akan akan menghapus image ini?"),
      actions: [
        ElevatedButton(
          child: Text("Iya"),
          onPressed: () async {
            int result = await DataBaseMain.db.deleteImage(image.imgId);
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

  int _maxAktId;
  _saveImage() async {
    try {
      for (int i = 0; i < f.length; i++) {
        // int result;

        _maxAktId = await DataBaseMain.db.maxAktId();
        // final bytes = File(f[i]).readAsBytesSync();
        // String imgString = Utility.base64String(bytes);
        String imgString = f[i];
        ImagesAttrb image = ImagesAttrb(widget.aktivitas == null
            ? {
                "imgImage": imgString,
                "imgName": _aktivitasName.text,
                "aktivitasId": _maxAktId
              }
            : {
                "imgImage": imgString,
                "imgName": widget.aktivitas.aktivitasName,
                "aktivitasId": widget.aktivitas.aktivitasId
              });

        await DataBaseMain.db.insertImage(image);

        _sharedFiles.clear();
        _intentDataStreamSubscription.cancel();
      }
    } on Exception catch (e) {
      _showSnackBar(context, e.toString());
    }
  }

  void getImageList() async {
    // try {

    Future<List<ImagesAttrb>> imageListFuture =
        DataBaseMain.db.getImage(widget.aktivitas.aktivitasId);
    imageListFuture.then((contactList) {
      setState(() {
        this.imageList = contactList;
        this.count = contactList.length;
      });
    });
    // } on Exception catch (e) {
    //   _showSnackBar(context, e.toString());
    // }
  }
}
