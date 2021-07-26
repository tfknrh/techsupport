import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:techsupport/controllers/c_category.dart';
import 'package:techsupport/controllers/c_aktivitas.dart';
import 'package:techsupport/controllers/c_setting.dart';
import 'package:techsupport/utils/u_color.dart';
import 'package:techsupport/utils/u_time.dart';

import 'package:techsupport/utils/u_filesize.dart';
import 'package:techsupport/widgets/w_customTimePicker.dart';
import 'package:techsupport/widgets/w_customSwitch.dart';
import 'package:techsupport/widgets/w_groupedList.dart';
import 'package:techsupport/widgets/w_text.dart';
import 'package:techsupport/models/m_setting.dart';
import 'package:theme_mode_handler/theme_mode_handler.dart';

import 'package:intl/intl.dart';

import 'package:techsupport/utils/u_notification.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Color _tempShadeColor = Colors.blueAccent[100];
  Color _shadeColor = Colors.blue[800];

  Setting setting = Setting();

  bool ready = false;
  String fileId;

  @override
  void initState() {
    super.initState();

    _initData();
    // addItemlist();
  }

  _initData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<SettingProvider>(context, listen: false).initData();
    });
  }

  int _intTable;
  var valTable = <String>["Aktivitas", "Customer", "Images"];
  String strTable;

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
                    setState(() => MColors.main = _tempShadeColor);
                    Provider.of<AktivitasProvider>(context, listen: false)
                        .update();
                    Provider.of<AktivitasProvider>(context, listen: false)
                        .update();
                    Provider.of<CategoryProvider>(context, listen: false)
                        .update();
                  },
                ),
              ],
            ));
      },
    );
  }

  static const themeModeOptions = [
    {'label': 'Sistem', 'value': ThemeMode.system, 'icon': Icons.settings},
    {'label': 'Cerah', 'value': ThemeMode.light, 'icon': Icons.wb_sunny},
    {
      'label': 'Gelap',
      'value': ThemeMode.dark,
      'icon': MaterialCommunityIcons.moon_full
    },
  ];
  static void _selectThemeMode(BuildContext context, ThemeMode value) async {
    ThemeModeHandler.of(context).saveThemeMode(value);
    Navigator.pop(context, value);
  }

  static Future<ThemeMode> showThemePickerDialog(
      {@required BuildContext contexts}) {
    return showDialog(
        context: contexts,
        builder: (context) {
          return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: SimpleDialog(
                backgroundColor: MColors.dialogsColor(context),
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                title: Text('Pilih Tema',
                    style: CText.primarycustomText(2, context, 'RobotoMedium')),
                children: themeModeOptions.map((option) {
                  return SimpleDialogOption(
                    onPressed: () =>
                        _selectThemeMode(contexts, option['value']),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(option['icon'],
                              color: Theme.of(context).accentColor),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            option['label'],
                            style: CText.primarycustomText(
                                1.8, context, 'RobotoMedium'),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ));
        });
  }

  Widget _buildGroupSeparator(dynamic groupByValue) {
    return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        child: groupByValue.toString() == "Backup ke GDrive"
            ? Row(children: [
                Icon(
                  AntDesign.google,
                  color: MColors.buttonColor(),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(groupByValue.toString(),
                    style: CText.primarycustomText(
                        1.7, context, 'CircularStdBook'))
              ])
            : groupByValue.toString() == "Tampilan"
                ? Row(children: [
                    Icon(
                      Icons.colorize,
                      color: MColors.buttonColor(),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(groupByValue.toString(),
                        style: CText.primarycustomText(
                            1.7, context, 'CircularStdBook'))
                  ])
                : Text(groupByValue.toString(),
                    style: CText.primarycustomText(
                        1.7, context, 'CircularStdBook')));
  }

  addItemlist() {}
  TimeOfDay _sch;
  NotificationManager notificationManager = NotificationManager();
  @override
  Widget build(BuildContext context) {
    String languageCode = Localizations.localeOf(context).toLanguageTag();

    final _size = MediaQuery.of(context).size;

    return Consumer<SettingProvider>(builder: (context, value, child) {
      return Scaffold(
        backgroundColor: MColors.backgroundColor(context),
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          backgroundColor: MColors.backgroundColor(context),
          elevation: 0,
          title: Text(
            "Setting",
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
              GroupedListView<ItemSetting, String>(
                shrinkWrap: true,
                elements: value.itemSetting,
                groupBy: (ItemSetting _setting) => _setting.group,
                order: GroupedListOrder.DESC,
                separator: Divider(
                  color: MColors.secondaryTextColor(context),
                ),
                //  useStickyGroupSeparators: true,
                groupSeparatorBuilder: _buildGroupSeparator,
                itemBuilder: (c, ItemSetting _setting) {
                  return SettingItem(
                    setting: _setting,
                    onTap: () {
                      if (_setting.title == "Tema") {
                        showThemePickerDialog(contexts: this.context);
                      } else if (_setting.title == "Color") {
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
                      }
                      // else if (_setting.tipe == 2) {
                      //   value.uploadtoGdrive();
                      //   }
                      else if (_setting.title == "Schedule") {
                        showCustomTimePicker(
                          initialTime: TimeOfDay.now(),
                          context: context,
                          builder: (BuildContext context, Widget child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                primaryColor: Colors.black,
                                accentColor: MColors.buttonColor(),
                              ),
                              child: child,
                            );
                          },
                        ).then((_value) {
                          if (_value != null) {
                            value.timeSelected = _value;
                            value.updateScheduler(TimeValidator.dateandTime(
                                DateTime.now(), _value));
                            _initData();
                          }
                        });
                      }
                    },
                  );
                },
              ),
              // ListView.separated(
              //     shrinkWrap: true,
              //     itemBuilder: (context, index) {
              //       return SettingItem(
              //         setting: _itemList[index],
              //         onTap: () {
              //           if (_itemList[index].title == "Tema") {
              //             showThemePickerDialog(contexts: this.context);
              //           } else if (_itemList[index].title == "Color") {
              //             _openDialog(
              //               "Select Color",
              //               MaterialColorPicker(
              //                 shrinkWrap: true,
              //                 selectedColor: _shadeColor,
              //                 onColorChange: (color) =>
              //                     setState(() => _tempShadeColor = color),
              //                 onBack: () => print("Back button pressed"),
              //               ),
              //             );
              //           } else if (_itemList[index].title == "Backup") {
              //             uploadtoGdrive();
              //           } else if (_itemList[index].title == "Schedule") {
              //             showCustomTimePicker(
              //               initialTime: TimeOfDay.now(),
              //               context: context,
              //               builder: (BuildContext context, Widget child) {
              //                 return Theme(
              //                   data: Theme.of(context).copyWith(
              //                     primaryColor: Colors.black,
              //                     accentColor: MColors.buttonColor(),
              //                   ),
              //                   child: child,
              //                 );
              //               },
              //             ).then((value) {
              //               if (value != null) {
              //                 _sch = value;
              //                 // if (value != null) {
              //                 //   _itemList[index].
              //                 //       "${TimeValidator.needZero(aktivitas.timeStart.hour)}:${TimeValidator.needZero(aktivitas.timeStart.minute)}";
              //                 //}
              //               }
              //             });
              //           }
              //         },
              //       );
              //     },
              //     separatorBuilder: (context, index) {
              //       return Divider(
              //         color: MColors.secondaryTextColor(context),
              //       );
              //     },
              //     itemCount: _itemList.length)
              // InkWell(
              //   onTap: () {
              //     _openDialog(
              //       "Select Color",
              //       MaterialColorPicker(
              //         shrinkWrap: true,
              //         selectedColor: _shadeColor,
              //         onColorChange: (color) =>
              //             setState(() => _tempShadeColor = color),
              //         onBack: () => print("Back button pressed"),
              //       ),
              //     );
              //   },
              //   splashColor: Colors.transparent,
              //   highlightColor: Colors.transparent,
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(vertical: 10.0),
              //     child: Row(
              //       children: [
              //         Icon(
              //           Icons.colorize,
              //           color: MColors.buttonColor(),
              //         ),
              //         SizedBox(
              //           width: _size.width * .02,
              //         ),
              //         Expanded(
              //           child: Text(
              //             "Color",
              //             style: CText.primarycustomText(
              //                 1.7, context, 'CircularStdBook'),
              //           ),
              //         ),
              //         SizedBox(
              //           width: _size.width * 0.04,
              //         ),
              //         Icon(
              //           Icons.keyboard_arrow_right,
              //           color: Theme.of(context).iconTheme.color,
              //         )
              //       ],
              //     ),
              //   ),
              // ),
              // Divider(
              //   color: MColors.secondaryTextColor(context),
              // ),
              // InkWell(
              //   splashColor: Colors.transparent,
              //   highlightColor: Colors.transparent,
              //   onTap: () {
              //     showThemePickerDialog(contexts: this.context);
              //   },
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(vertical: 10.0),
              //     child: Row(
              //       children: [
              //         Icon(
              //           MaterialCommunityIcons.theme_light_dark,
              //           color: MColors.buttonColor(),
              //         ),
              //         SizedBox(
              //           width: _size.width * .02,
              //         ),
              //         Expanded(
              //           child: Text(
              //             "Ganti Tema",
              //             style: CText.primarycustomText(
              //                 1.7, context, 'CircularStdBook'),
              //           ),
              //         ),
              //         SizedBox(
              //           width: _size.width * 0.04,
              //         ),
              //         Icon(
              //           Icons.keyboard_arrow_right,
              //           color: Theme.of(context).iconTheme.color,
              //         )
              //       ],
              //     ),
              //   ),
              // ),

              // Divider(
              //   color: MColors.secondaryTextColor(context),
              // ),
              // InkWell(
              //   splashColor: Colors.transparent,
              //   highlightColor: Colors.transparent,
              //   onTap: () {},
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(vertical: 10.0),
              //     child: Row(
              //       children: [
              //         Icon(
              //           AntDesign.google,
              //           color: MColors.buttonColor(),
              //         ),
              //         SizedBox(
              //           width: _size.width * .02,
              //         ),
              //         Expanded(
              //           child: Text(
              //             "Backup to Google Drive",
              //             style: CText.primarycustomText(
              //                 1.7, context, 'CircularStdBook'),
              //           ),
              //         ),
              //         SizedBox(
              //           width: _size.width * 0.04,
              //         ),
              //         // Icon(
              //         //   Icons.keyboard_arrow_right,
              //         //   color: Theme.of(context).iconTheme.color,
              //         // )
              //       ],
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 10),
              //   child:
            ],
          ),
        ),
        // ),
      );
    });
  }
}

class SettingItem extends StatefulWidget {
  final Function onTap;
  final Function onLongPress;
  final ItemSetting setting;
  //final Widget trailing;

  const SettingItem({Key key, this.onTap, this.onLongPress, this.setting})
      : super(key: key);

  @override
  _SettingItemState createState() => _SettingItemState();
}

class _SettingItemState extends State<SettingItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
          left: 40,
          right: 20,
        ),
        child: ListTile(
          trailing: widget.setting.tipe == 2
              ? Container(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<SettingProvider>(context, listen: false)
                          .uploadtoGdrive();
                      Provider.of<SettingProvider>(context, listen: false)
                          .initData();
                    },
                    child: Text(
                      widget.setting.title,
                    ),
                  ))
              : Text(""),
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          title: widget.setting.tipe == 1
              ? Text(widget.setting.title,
                  style:
                      CText.primarycustomText(1.7, context, 'CircularStdBook'))
              : Text(""),
          subtitle: Text(
            widget.setting.subtitle,
            style: CText.secondarycustomText(1.5, context, 'CircularStdBook'),
          ),
        ));
  }
}
